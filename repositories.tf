module "org_mgmt" {
  source   = "./modules/repository"
  name     = "org-mgmt"
  archived = false
  topics   = []
}

module "scribe" {
  source    = "./modules/repository"
  name      = "scribe"
  archived  = false
  is_public = true
}

module "manifests" {
  source    = "./modules/repository"
  name      = "manifests"
  archived  = false
  is_public = true
}

module "infra" {
  source    = "./modules/repository"
  name      = "infra"
  archived  = false
  is_public = true
}

module "charts" {
  source       = "./modules/repository"
  name         = "charts"
  archived     = false
  is_public    = true
  enable_pages = true
}
