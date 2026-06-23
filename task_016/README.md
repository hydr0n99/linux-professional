# PAM

## Цель

Научиться создавать пользователей и добавлять им ограничения

## Описание/Пошаговая инструкция выполнения домашнего задания:

Ограничить доступ к системе для всех пользователей, кроме группы администраторов, в выходные дни (суббота и воскресенье), за исключением праздничных дней.

Задание повышенной сложности:
* предоставить определённому пользователю доступ к Docker и право перезапускать Docker-сервис.

# Выполнение

Была развёрнута виртуальная машина с помощью данного [Vagrantfile](./Vagrantfile).

## Создание пользователей

Подключимся к ВМ с помощью `vagrant ssh`, перейдём под root с помощью `sudo -i` и создадим несколько пользователей, а также зададим им пароли

```
useradd otusadm && useradd otus-user-1 && useradd otus-user-2
echo '12345678' | passwd --stdin otusadm && echo '12345678' | passwd --stdin otus-user-1 && echo '12345678' | passwd --stdin otus-user-2
```

Создадим группу `admins` и поместим туда пользователей root, vagrant и otusadm:

```
groupadd -f admins
usermod root -a -G admins && usermod vagrant -a -G admins && usermod otusadm -a -G admins
```

Убедимся, что пользователи добавлены в группу, позвав `cat /etc/group | grep admins`:

```
admins:x:1004:root,vagrant,otusadm
```

После чего можно подключиться по ssh под любым из добавленный пользователей и убедиться, что подключение удаётся:

```
ssh <username>@192.168.56.10
```

ИЛИ

```
ssh -p 2222 <username>@127.0.0.1
```

## Ограничение прав и свобод

Поместим скрипт [login.sh](./login.sh) в директорию `/usr/local/bin/` и добавим такую строку в `/etc/pam.d/sshd`:

```
auth required pam_exec.so debug /usr/local/bin/login.sh
```

Всё это (ну, кроме подключения по ssh) можно в автоматическом режиме сделать с помощью [`provision.sh`](./provision.sh) при разворачивании ВМ (что я в итоге и добавил, но удалять подробное описание было жалко).

Далее осталось проверить, что всё работает как ожидается.

## Проверка работоспособности

Нужно принудительно установить дату на субботу/воскресенье, чтобы убедиться, что пользователи НЕ из группы `admins` не имеют доступа в систему.

Выполним `ps aux | grep VBox`, чтобы узнать PID процесса VBoxService, который синхронизирует время в ВМ с хостовым:

```
root 895 0.0 0.1 218776 2452 ? Sl 21:21 0:01 /usr/bin/VBoxDRMClient
root 897 0.0 0.2 356072 4192 ? Sl 21:21 0:00 /usr/sbin/VBoxService --pidfile /var/run/vboxadd-service.sh
root 4926 0.0 0.1 6416 2412 pts/0 S+ 22:10 0:00 grep --color=auto VBox
```

Убьём процесс 897 с помощью `kill 897`, а затем отключим NTP и установим дату на 21.06.2026 (воскресенье):

```
timedatectl set-ntp false
timedatectl set-time "2026-06-21 12:00:00"
```

Теперь попробуем подключиться по ssh под пользователем `otus-user-1`:

```
otus-user-1@192.168.56.10's password: 
Permission denied, please try again.
```

Пароль, разумеется, вводится верный.

Теперь под пользователем `otusadm`:

```
otusadm@192.168.56.10's password: 
Last failed login: Tue Jun 23 21:57:24 UTC 2026 from 192.168.56.1 on ssh:notty
There were 3 failed login attempts since the last successful login.
Last login: Sun Jun 21 15:31:49 2026 from 192.168.56.1
[otusadm@localhost ~]$
```

Логин происходит успешно.
