# Virtual Box

Installs the Virtual Box and its extension package.

## Requirements

EPEL repository is needed on Red Hat and CentOS and based distributions. You can use for example (https://galaxy.ansible.com/geerlingguy/repo-epel](Ansible Role: EPEL Repository)

## Role Variables

If needed, the package name can be changed by specifying the `virtualbox_package` variable. It defaults to `virtualbox-6.1`

## Dependencies

None.

## Example Playbook

    - hosts: "servers"
      roles:
         - "mireiawen.virtualbox"

## License
MIT, see `LICENSE`
