# Строим бонды и вланы

## Цель

Научиться настраивать VLAN и LACP

## Описание/Пошаговая инструкция выполнения домашнего задания:

в Office1 в тестовой подсети появляется сервера с доп интерфейсами и адресами
в internal сети testLAN:

* testClient1 - 10.10.10.254
* testClient2 - 10.10.10.254
* testServer1- 10.10.10.1
* testServer2- 10.10.10.1

Развести вланами:
testClient1 <-> testServer1
testClient2 <-> testServer2

Между centralRouter и inetRouter "пробросить" 2 линка (общая inernal сеть) и объединить их в бонд, проверить работу c отключением интерфейсов

## Выполнение

В качестве хоста используется ВМ под управлением Ubuntu 24.04 с 24 ГБ RAM на борту и 6 ядрами, а также вложенной виртуализацией.

* [Vagrantfile](./Vagrantfile)
* [Ansible-playbook для provison](./ansible/provision.yml)
* [Вспомогательные файлы](./ansible/templates) и [hosts](./ansible/hosts)
