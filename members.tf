module "shanduur" {
  source   = "./modules/member"
  username = "shanduur"
  role     = "admin"
}

module "shanduur_auto" {
  source   = "./modules/member"
  username = "shanduur-auto"
  role     = "admin"
}

module "niesmaczne" {
  source   = "./modules/member"
  username = "niesmaczne"
}

module "team_core" {
  source  = "./modules/team"
  name    = "core"
  privacy = "closed"
  members = [
    { username = module.shanduur.username, role = "maintainer" },
    { username = module.niesmaczne.username },
  ]
}

module "team_bots" {
  source = "./modules/team"
  name   = "bots"
  members = [
    { username = module.shanduur_auto.username, role = "maintainer" },
  ]
}
