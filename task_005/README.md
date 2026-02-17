# Работа с NFS

## Цель

Научиться самостоятельно разворачивать сервис NFS и подключать к нему клиентов

## Описание/Пошаговая инструкция выполнения домашнего задания:

1. Запустить 2 виртуальных машины (сервер NFS и клиента)
2. На сервере NFS должна быть подготовлена и экспортирована директория
3. В экспортированной директории должна быть поддиректория с именем upload с правами на запись в неё;
4. Экспортированная директория должна автоматически монтироваться на клиенте при старте виртуальной машины (systemd, autofs или fstab — любым способом)
5. Монтирование и работа NFS на клиенте должна быть организована с использованием NFSv3.

# Выполнение

## Подготовка

В VMWare были запущены 2 виртуальные машины с Ubuntu: 22.04 (IP: `192.168.2.111`) в качестве сервера, 24.04 (IP: `192.168.2.58`) в качестве клиента.

## Настройка сервера

Последовательность команд для настройки сервера описана в [`nfss_script.sh`](./nfss_script.sh). Выполняются под root'ом (`sudo -i`).

## Настройка клиента

Последовательность команд для настройки клиента описана в [`nfsc_script.sh`](./nfsc_script.sh). Выполняются под root'ом (`sudo -i`).

## Проверка работоспособности

На клиенте переместимся в директорию `/mnt` и проверим работоспособность через `mount | grep mnt`:

```
systemd-1 on /mnt type autofs (rw,relatime,fd=93,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=48603)
192.168.2.111:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,fatal_neterrors=none,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.2.111,mountvers=3,mountport=42134,mountproto=udp,local_lock=none,addr=192.168.2.111)
```

Сделаем `ls /mnt` и увидим только одну директорию `upload`. Создадим на сервере файл `test_file_1` в директории `upload`, а затем выполним `ls -lR /mnt` на клиенте:

```
/mnt:
total 4
drwxrwxrwx 2 nobody nogroup 4096 Feb 17 19:58 upload

/mnt/upload:
total 0
-rw-rw-r-- 1 hydr0n hydr0n 0 Feb 17 19:59 test_file_1
```

Затем на клиенте создадим в директории `upload` файл `test_file_2`, а на сервере выполним `ls -lR /srv/share`:

```
/srv/share:
total 4
drwxrwxrwx 2 nobody nogroup 4096 Feb 17 19:59 upload

/srv/share/upload:
total 0
-rw-rw-r-- 1 hydr0n hydr0n 0 Feb 17 19:59 test_file_1
-rw-rw-r-- 1 hydr0n hydr0n 0 Feb 17 19:59 test_file_2
```

Перезагрузим клиент и, зайдя в директория `/mnt`, выполним `ls -lR`:

```
.:
total 4
drwxrwxrwx 2 nobody nogroup 4096 Feb 17 19:59 upload

./upload:
total 0
-rw-rw-r-- 1 hydr0n hydr0n 0 Feb 17 19:59 test_file_1
-rw-rw-r-- 1 hydr0n hydr0n 0 Feb 17 19:59 test_file_2
```

Перезагрузим сервер и проверим наличие файлов с помощью `ls -lR /srv/share`:

```
/srv/share:
total 4
drwxrwxrwx 2 nobody nogroup 4096 Feb 17 19:59 upload

/srv/share/upload:
total 0
-rw-rw-r-- 1 hydr0n hydr0n 0 Feb 17 19:59 test_file_1
-rw-rw-r-- 1 hydr0n hydr0n 0 Feb 17 19:59 test_file_2
```

Проверим `exportfs -s` на сервере:

```
/srv/share  192.168.2.58/32(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```

Проверим `showmount -a 192.168.2.111` на сервере:

```
All mount points on 192.168.2.111:
192.168.2.58:/srv/share
```

Перезагрузим клиент и выполним на нём `showmount -a 192.168.2.111`:

```
All mount points on 192.168.2.111:
192.168.2.58:/srv/share
```

Затем перейдём в `/mnt/upload` и проверим статус монтирования с помощью `mount | grep mnt`:

```
systemd-1 on /mnt type autofs (rw,relatime,fd=49,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=13743)
192.168.2.111:/srv/share/ on /mnt type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,fatal_neterrors=none,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.2.111,mountvers=3,mountport=59712,mountproto=udp,local_lock=none,addr=192.168.2.111)
```

Проверим наличие ранее созданных файлов с помощью `ls -lR /mnt`:

```
/mnt:
total 4
drwxrwxrwx 2 nobody nogroup 4096 Feb 17 19:59 upload

/mnt/upload:
total 0
-rw-rw-r-- 1 hydr0n hydr0n 0 Feb 17 19:59 test_file_1
-rw-rw-r-- 1 hydr0n hydr0n 0 Feb 17 19:59 test_file_2
```

Создадим файл `test_file_3` на клиенте и проверим его наличие на сервере с помощью `ls -lR /srv/share`:

```
/srv/share:
total 4
drwxrwxrwx 2 nobody nogroup 4096 Feb 17 20:16 upload

/srv/share/upload:
total 0
-rw-rw-r-- 1 hydr0n hydr0n 0 Feb 17 19:59 test_file_1
-rw-rw-r-- 1 hydr0n hydr0n 0 Feb 17 19:59 test_file_2
-rw-rw-r-- 1 hydr0n hydr0n 0 Feb 17 20:16 test_file_3
```

Демонстрационный стенд работоспособен и готов к работе.
