# Luc-Assure

Plateforme d'infrastructure automatisée et sécurisée simulant une compagnie d'assurance québécoise — projet portfolio DevOps / DevSecOps / SRE.

Voir `docs/architecture.md` pour la description complète du projet.

## Statut

- [x] Structure du dépôt
- [x] Module Terraform VPC
- [ ] Backend Terraform déployé (S3 + DynamoDB)
- [ ] VPC déployé sur AWS
- [ ] Module EKS
- [ ] Premier microservice conteneurisé
- [ ] Pipeline GitHub Actions

## Démarrage — Jour 1

### 1. Prérequis à installer

```bash
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# Terraform (via tfenv recommandé pour gérer les versions)
brew install tfenv        # macOS
# ou télécharger le binaire depuis https://developer.hashicorp.com/terraform/install
tfenv install 1.9.0
tfenv use 1.9.0

# Vérifier
aws --version
terraform --version
```

### 2. Configurer tes accès AWS

```bash
aws configure
# AWS Access Key ID, Secret Access Key, région (us-east-1), format (json)
```

> Utilise un compte AWS avec le Free Tier, et **crée un utilisateur IAM dédié** (jamais le compte root) avec uniquement les permissions nécessaires. Active la MFA sur le compte root.

### 3. Déployer le backend Terraform distant (une seule fois)

```bash
cd infra/terraform/bootstrap
terraform init
terraform plan
terraform apply
```

Cela crée le bucket S3 et la table DynamoDB qui stockeront le state de tous les environnements suivants.

### 4. Déployer le VPC de l'environnement dev

```bash
cd ../envs/dev
terraform init
terraform plan
terraform apply
```

Vérifie ensuite dans la console AWS (VPC) que le réseau, les subnets, le NAT Gateway et les tables de routage sont bien créés.

### 5. Ne pas oublier

```bash
# Une fois les tests terminés pour la journée, détruis les ressources
# pour éviter les frais (le VPC seul est gratuit, mais le NAT Gateway
# et l'EIP associée sont facturés à l'heure)
terraform destroy
```

## Structure du dépôt

```
luc-assure/
├── infra/terraform/
│   ├── bootstrap/        # backend S3 + DynamoDB (déployé une fois)
│   ├── modules/vpc/      # module réseau réutilisable
│   └── envs/dev/         # environnement dev qui consomme les modules
├── docs/
└── README.md
```
