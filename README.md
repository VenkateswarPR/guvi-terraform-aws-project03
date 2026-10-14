**GUVI Project 03: AWS Infrastructure Automation Using Terraform & GitHub Actions**

Provisions AWS infrastructure with Terraform and deploys it through a GitHub Actions pipeline with a manual approval gate.

**Architecture**

- **Networking module** (`modules/networking`): VPC, two public subnets, Internet Gateway, public route table and associations
- **Compute module** (`modules/compute`): EC2 instance (Amazon Linux, Nginx via User Data), Elastic IP, security group, IAM role and instance profile
- **Root configuration**: calls both modules and creates the application S3 bucket (versioning, AES256 encryption, public access block)
- **Remote state**: S3 backend with native state locking (`use_lockfile = true`); state is never committed

**Repository structure**

```
.
├── .github/workflows/terraform.yml   # CI/CD pipeline
├── modules/
│   ├── networking/
│   └── compute/
├── backend.tf        # S3 remote state + locking
├── providers.tf
├── main.tf           # module calls + S3 bucket
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
└── .gitignore
```

**Variables**

| Variable | Description | Default |
|---|---|---|
| `aws_region` | AWS region | `ap-south-1` |
| `environment` | Environment name | `dev` |
| `vpc_cidr` | VPC CIDR | `10.10.0.0/16` |
| `public_subnet_cidrs` | Two public subnet CIDRs | `10.10.1.0/24`, `10.10.2.0/24` |
| `instance_type` | EC2 instance type | `t3.micro` |
| `ami_id` | Amazon Linux AMI ID (set via GitHub variable `AMI_ID`) | none |
| `ssh_allowed_cidr` | Your IP for SSH, `/32` (GitHub variable `SSH_ALLOWED_CIDR`) | none |

**Outputs**

`vpc_id`, `ec2_instance_id`, `elastic_ip`, `application_url`, `s3_bucket_name`, `security_group_id`, `iam_role_name`

**CI/CD workflow**

Triggered on every push to `main` (and manually).

1. **Plan job**: Checkout, Terraform Format check, Init, Validate, Plan, upload the plan as the `terraform-plan` artifact
2. **Apply job** (environment `production`, requires manual approval): downloads the approved plan, Terraform Apply, displays Terraform Outputs, then validates the infrastructure (EC2 running, Elastic IP, S3 settings, IAM role, security group, HTTP 200 from the web server)

AWS access uses GitHub OIDC with an IAM role, so no AWS keys are stored in the repository.

**Setup**

1. Create the S3 state bucket and set it in `backend.tf`
2. Create the GitHub OIDC provider and an IAM role trusted by this repository
3. In GitHub: add secret `AWS_ROLE_ARN`; add variables `AMI_ID` and `SSH_ALLOWED_CIDR`; create environment `production` with Required reviewers
4. Push to `main`, review the plan artifact, approve the deployment

**Security**

- IAM role with a least-privilege policy (access to the application bucket only)
- Security group allows HTTP (80) and SSH only from one approved IP
- IMDSv2 required, encrypted root volume
- S3 bucket: versioning, encryption, all public access blocked
- Terraform state is remote, encrypted and excluded from Git

**Application URL**

See the `application_url` output of the latest workflow run.
