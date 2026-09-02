#!/bin/bash
# =============================================================================
# end-of-session.sh
#
# Script à lancer À LA FIN DE CHAQUE SESSION de travail sur luc-assure.
#
# Objectif : détruire proprement l'infrastructure Terraform de l'environnement
# dev, PUIS vérifier par un balayage multi-régions qu'il ne reste vraiment
# plus aucune ressource facturable orpheline nulle part sur le compte.
#
# Créé suite à l'incident de facturation d'août 2026 (cluster EKS de test
# oublié, ~530 USD de frais non détectés pendant 26 jours car non géré par
# Terraform et hors de la région du projet).
#
# Usage :
#   chmod +x end-of-session.sh
#   ./end-of-session.sh
# =============================================================================

set -uo pipefail

REGIONS=("us-east-1" "us-east-2" "us-west-1" "us-west-2" "ca-central-1" "eu-west-1")
PROJECT_ENV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../infra/terraform/envs/dev" && pwd)"

echo "======================================================================"
echo " ÉTAPE 1 — Destruction de l'infrastructure Terraform (env: dev)"
echo "======================================================================"
cd "$PROJECT_ENV_DIR" || { echo "❌ Impossible d'accéder à $PROJECT_ENV_DIR"; exit 1; }

echo "État actuel avant destruction :"
terraform state list

read -p $'\nConfirmer la destruction Terraform complète de cet environnement ? (yes/no) : ' CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Destruction annulée. Le balayage de vérification va quand même être lancé ci-dessous."
else
    terraform destroy
fi

echo ""
echo "======================================================================"
echo " ÉTAPE 2 — Balayage multi-régions : instances EC2 actives"
echo "======================================================================"
for region in "${REGIONS[@]}"; do
    echo "=== $region ==="
    aws ec2 describe-instances --region "$region" \
        --filters "Name=instance-state-name,Values=running" \
        --query "Reservations[].Instances[].InstanceId" --output text
done

echo ""
echo "======================================================================"
echo " ÉTAPE 3 — Balayage multi-régions : clusters EKS"
echo "======================================================================"
for region in "${REGIONS[@]}"; do
    echo "=== $region ==="
    aws eks list-clusters --region "$region" --query "clusters" --output text
done

echo ""
echo "======================================================================"
echo " ÉTAPE 4 — Balayage multi-régions : Load Balancers"
echo "======================================================================"
for region in "${REGIONS[@]}"; do
    echo "=== $region ==="
    aws elbv2 describe-load-balancers --region "$region" \
        --query "LoadBalancers[].LoadBalancerArn" --output text
    aws elb describe-load-balancers --region "$region" \
        --query "LoadBalancerDescriptions[].LoadBalancerName" --output text
done

echo ""
echo "======================================================================"
echo " ÉTAPE 5 — Balayage multi-régions : NAT Gateways"
echo "======================================================================"
for region in "${REGIONS[@]}"; do
    echo "=== $region ==="
    aws ec2 describe-nat-gateways --region "$region" \
        --filter "Name=state,Values=available" \
        --query "NatGateways[].NatGatewayId" --output text
done

echo ""
echo "======================================================================"
echo " ÉTAPE 6 — Balayage multi-régions : Elastic IPs non attachées"
echo "======================================================================"
for region in "${REGIONS[@]}"; do
    echo "=== $region ==="
    aws ec2 describe-addresses --region "$region" \
        --query "Addresses[?AssociationId==null].PublicIp" --output text
done

echo ""
echo "======================================================================"
echo " ÉTAPE 7 — Balayage multi-régions : volumes EBS non attachés"
echo "======================================================================"
for region in "${REGIONS[@]}"; do
    echo "=== $region ==="
    aws ec2 describe-volumes --region "$region" \
        --filters "Name=status,Values=available" \
        --query "Volumes[].VolumeId" --output text
done

echo ""
echo "======================================================================"
echo " ÉTAPE 8 — Balayage multi-régions : instances RDS"
echo "======================================================================"
for region in "${REGIONS[@]}"; do
    echo "=== $region ==="
    aws rds describe-db-instances --region "$region" \
        --query "DBInstances[].DBInstanceIdentifier" --output text
done

echo ""
echo "======================================================================"
echo " TERMINÉ"
echo "======================================================================"
echo "Vérifie ci-dessus qu'AUCUNE ligne non vide n'apparaît sous chaque"
echo "région/service. Si quelque chose apparaît, ne quitte pas ta session"
echo "avant de l'avoir identifié et supprimé manuellement."
echo ""
echo "Rappel : le budget AWS (luc-assure-dev-monthly-budget) reste actif en"
echo "permanence et est gratuit — il t'enverra un courriel si un seuil de"
echo "dépense est atteint, en plus de ce script."
