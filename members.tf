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
  source = "./modules/team"
  name   = "core"
  members = [
    { username = module.shanduur.username, role = "maintainer" },
    { username = module.shanduur_auto.username, role = "maintainer" },
    { username = module.niesmaczne.username },
  ]
}
