# hublue

A custom re-build of Fedora Silverblue, with my most commonly used packages in the base image rather than rpm-ostree
layers.

## To build this for yourself:

Set up some vars, to make things easier.

```shell
## The base version of silverblue you want to use,
## it will be passed to the container as a build arg
export SB_VERSION="40" 
## A re-usable reference to the image
export CUSTOM_SB="fedora-siverblue-${USER}:${SB_VERSION}"
```

### Rootless build

``` shell
buildah bud --build-arg SB_VERSION="${SB_VERSION}" -t "${CUSTOM_SB}" .
skopeo copy containers-storage:localhost/"${CUSTOM_SB}" oci:"${CUSTOM_SB}"
rpm-ostree rebase ostree-unverified-image:oci:/var/home/"${USER}"/git/my-oci-image/"${CUSTOM_SB}"
rpm-ostree status
systemctl reboot
```

```shell
sudo buildah bud --build-arg SB_VERSION="${SB_VERSION}" -t "${CUSTOM_SB}" .
rpm-ostree rebase ostree-unverified-image:containers-storage:localhost/"${CUSTOM_SB}"
rpm-ostree status
systemctl reboot
```

## Kudos

Big thanks to @juanje for the sharing his setup. All of this was thanks to his guidance.