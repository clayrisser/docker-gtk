variable "BAKE_OUTPUT" {}
variable "DOCKER_REGISTRY" {}
variable "DOCKER_TAG" {}
variable "GIT_COMMIT" {}

group "default" {
  targets = ["docker-gtk"]
}

target "_common" {
  context = ".."
  output  = ["type=${BAKE_OUTPUT}"]
}

target "docker-gtk" {
  inherits   = ["_common"]
  dockerfile = "docker/Dockerfile"
  tags = [
    "${DOCKER_REGISTRY}/docker-gtk:${DOCKER_TAG}",
    "${DOCKER_REGISTRY}/docker-gtk:${GIT_COMMIT}",
  ]
}
