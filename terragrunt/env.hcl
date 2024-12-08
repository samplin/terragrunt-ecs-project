locals {
  name = "hello-world"
  region = "us-west-2"
  cwd       = run_cmd("--terragrunt-quiet", "pwd")
  account_id = run_cmd("--terragrunt-quiet", "aws", "sts", "get-caller-identity", "--query", "Account", "--output", "text")
  app_path  = "${local.cwd}/../apps"
  timestamp = run_cmd("--terragrunt-quiet", "date", "+%s")
  container_port = 5000
  tags = {
    Environment = "Development"
    Project     = "HelloWorld"
  }
}
