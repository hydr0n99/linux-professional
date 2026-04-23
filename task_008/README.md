# Systemd - создание unit-файла

## Цель

Научиться редактировать существующие и создавать новые unit-файлы.

## Описание/Пошаговая инструкция выполнения домашнего задания:

Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):

1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/default).
2. Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта (https://gist.github.com/cea2k/1318020).
3. Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно.

# Выполнение

## Подготовка

В качестве хоста использовался ПК с Windows 11. Провайдер - VMWare (его плагин для Vagrant невероятно тормознутый, конечно). Гостевая ОС - Ubuntu 22.04.

[Vagrantfile](./Vagrantfile) содержит описание разворачиваемой ВМ. Указанный в нём Provsion-файл будем заменять в зависимости от пункта задания и пересоздавать ВМ (для "чистоты эксперимента").

## Сервис мониторинга

Укажем в Vagrantfile соответствующий [соответствующий provision](./provision-watchlog.sh) и запустим ВМ с помощью `vagrant up --provider=vmware_desktop`. Увидим такой лог:

```
Bringing machine 'default' up with 'vmware_desktop' provider...
==> default: Cloning VMware VM: 'bento/ubuntu-22.04'. This can take some time...
==> default: Checking if box 'bento/ubuntu-22.04' version '202510.26.0' is up to date...
==> default: Verifying vmnet devices are healthy...
==> default: Preparing network adapters...
==> default: Starting the VMware VM...
==> default: Waiting for the VM to receive an address...
==> default: Forwarding ports...
    default: -- 22 => 2222
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default:
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default:
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Configuring network adapters within the VM...
==> default: Waiting for HGFS to become available...
==> default: Enabling and configuring shared folders...
    default: -- C:/vagrant: /vagrant
==> default: Running provisioner: shell...
    default: Running: C:/Users/dudka/AppData/Local/Temp/vagrant-shell20260423-26984-c91rg7.sh
    default: Created symlink /etc/systemd/system/timers.target.wants/watchlog.timer → /etc/systemd/system/watchlog.timer.
```

Подключимся к ВМ с помощью `vagrant ssh`. Затем с помощью `tail -n 100 /var/log/syslog  | grep FATAL` убедимся в том, что таймер и сервис работают:

```
Apr 23 12:11:14 vagrant log-monitor: Thu Apr 23 12:11:14 PM UTC 2026: Word FATAL was found!
Apr 23 12:11:45 vagrant log-monitor: Thu Apr 23 12:11:45 PM UTC 2026: Word FATAL was found!
Apr 23 12:12:35 vagrant log-monitor: Thu Apr 23 12:12:35 PM UTC 2026: Word FATAL was found!
Apr 23 12:13:10 vagrant log-monitor: Thu Apr 23 12:13:10 PM UTC 2026: Word FATAL was found!
Apr 23 12:13:45 vagrant log-monitor: Thu Apr 23 12:13:45 PM UTC 2026: Word FATAL was found!
Apr 23 12:14:45 vagrant log-monitor: Thu Apr 23 12:14:45 PM UTC 2026: Word FATAL was found!
```

## Spawn-fcgi

Заменим в [Vagrantfile](./Vagrantfile) provision-файл на [provision-spawn-fcgi.sh](./provision-spawn-fcgi.sh) и пересоздадим машину, предварительно уничтожив предыдующую с помощью `vagrant destroy -f`.
Видим лог создания (в скоращённом виде):

```
...
default: Running kernel seems to be up-to-date.
default:
default: No services need to be restarted.
default:
default: No containers need to be restarted.
default:
default: No user sessions are running outdated binaries.
default:
default: No VM guests are running outdated hypervisor (qemu) binaries on this host.
default: Created symlink /etc/systemd/system/multi-user.target.wants/spawn-fcgi.service → /etc/systemd/system/spawn-fcgi.service.
```

Вновь подключаемся к ВМ с помощью `vagrant ssh` и проверяем работу spawn-fcgi (`systemctl status spawn-fcgi`):

```
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
     Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2026-04-23 12:22:06 UTC; 15min ago
   Main PID: 11041 (php-cgi)
      Tasks: 33 (limit: 2220)
     Memory: 14.3M
        CPU: 21ms
     CGroup: /system.slice/spawn-fcgi.service
             ├─11041 /usr/bin/php-cgi
             ├─11042 /usr/bin/php-cgi
             ├─11043 /usr/bin/php-cgi
             ├─11044 /usr/bin/php-cgi
             ├─11045 /usr/bin/php-cgi
             ├─11046 /usr/bin/php-cgi
             ├─11047 /usr/bin/php-cgi
             ├─11048 /usr/bin/php-cgi
             ├─11049 /usr/bin/php-cgi
             ├─11050 /usr/bin/php-cgi
             ├─11051 /usr/bin/php-cgi
             ├─11052 /usr/bin/php-cgi
             ├─11053 /usr/bin/php-cgi
             ├─11054 /usr/bin/php-cgi
             ├─11055 /usr/bin/php-cgi
             ├─11056 /usr/bin/php-cgi
             ├─11057 /usr/bin/php-cgi
             ├─11058 /usr/bin/php-cgi
             ├─11059 /usr/bin/php-cgi
             ├─11060 /usr/bin/php-cgi
             ├─11061 /usr/bin/php-cgi
```

## Запуск нескольки экземпляров Nginx одновременно

Снова уничтожаем ВМ с помощью `vagrant destroy -f`, меняем provision-файл в [Vagrantfile](./Vagrantfile) на [provision-nginx.sh](./provision-nginx.sh) и создаём новую ВМ с помощью `vagrant up --provider=vmware_desktop`. Лог (частичный):

```
...
default: Setting up nginx-core (1.18.0-6ubuntu14.8) ...
default:  * Upgrading binary nginx
default:    ...done.
default: Setting up nginx (1.18.0-6ubuntu14.8) ...
default: Processing triggers for ufw (0.36.1-4ubuntu0.1) ...
default: Processing triggers for man-db (2.10.2-1) ...
default: Processing triggers for libc-bin (2.35-0ubuntu3.11) ...
default:
default: Running kernel seems to be up-to-date.
default:
default: No services need to be restarted.
default:
default: No containers need to be restarted.
default:
default: No user sessions are running outdated binaries.
default:
default: No VM guests are running outdated hypervisor (qemu) binaries on this host.
```

И снова подключаемся к машине через ssh и проверяем, что сервисы запущены:

1. `systemctl status nginx@first`

```
● nginx@first.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/etc/systemd/system/nginx@.service; disabled; vendor preset: enabled)
     Active: active (running) since Thu 2026-04-23 12:45:11 UTC; 5min ago
       Docs: man:nginx(8)
    Process: 2661 ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-first.conf -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 2662 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 2663 (nginx)
      Tasks: 3 (limit: 2220)
     Memory: 3.4M
        CPU: 17ms
     CGroup: /system.slice/system-nginx.slice/nginx@first.service
             ├─2663 "nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on;"
             ├─2664 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""
             └─2665 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""
```

2. `systemctl status nginx@second`

```
● nginx@second.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/etc/systemd/system/nginx@.service; disabled; vendor preset: enabled)
     Active: active (running) since Thu 2026-04-23 12:45:11 UTC; 4min 34s ago
       Docs: man:nginx(8)
    Process: 2667 ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-second.conf -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 2668 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-second.conf -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 2669 (nginx)
      Tasks: 3 (limit: 2220)
     Memory: 3.3M
        CPU: 16ms
     CGroup: /system.slice/system-nginx.slice/nginx@second.service
             ├─2669 "nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-second.conf -g daemon on; master_process on;"
             ├─2670 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""
             └─2671 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""
```

Проверим также с помощью `ss -tnulp | grep nginx`, что порты прослушиваются:

```
tcp   LISTEN 0      511               0.0.0.0:9002      0.0.0.0:*    users:(("nginx",pid=2671,fd=6),("nginx",pid=2670,fd=6),("nginx",pid=2669,fd=6))
tcp   LISTEN 0      511               0.0.0.0:9001      0.0.0.0:*    users:(("nginx",pid=2665,fd=6),("nginx",pid=2664,fd=6),("nginx",pid=2663,fd=6))
tcp   LISTEN 0      511               0.0.0.0:80        0.0.0.0:*    users:(("nginx",pid=2617,fd=6),("nginx",pid=2616,fd=6),("nginx",pid=2614,fd=6))
tcp   LISTEN 0      511                  [::]:80           [::]:*    users:(("nginx",pid=2617,fd=7),("nginx",pid=2616,fd=7),("nginx",pid=2614,fd=7))
```

И, наконец, проверим с помощью `ps afx | grep nginx`, что имеется две группы процессов:

```
2663 ?        Ss     0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on;
2664 ?        S      0:00  \_ nginx: worker process
2665 ?        S      0:00  \_ nginx: worker process
2669 ?        Ss     0:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-second.conf -g daemon on; master_process on;
2670 ?        S      0:00  \_ nginx: worker process
2671 ?        S      0:00  \_ nginx: worker process
```
