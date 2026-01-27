terraform {
  backend "s3" {
    bucket = "qualquer-coisa-ai-332r233"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}
