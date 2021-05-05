provider "aws" { 
    region = "us-east-2" 
}

terraform { 
    backend "s3" { 
        key = "workspace-demo/terraform.tfstate"
    }
}

resource "aws_instance" "example" { 
  ami = "ami-0c55b159cbfafe1f0" 
  instance_type = "t2.micro" 
}