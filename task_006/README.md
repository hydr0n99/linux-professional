# Сборка RPM-пакета и создание репозитория

## Цель

Научиться собирать RPM-пакеты. Создавать собственный RPM-репозиторий.

## Описание/Пошаговая инструкция выполнения домашнего задания:

1. Создать свой RPM (можно взять свое приложение, либо собрать к примеру Apache с определенными опциями).
2. Создать свой репозиторий и разместить там ранее собранный RPM.
3. Реализовать это все либо в Vagrant, либо развернуть у себя через Nginx и дать ссылку на репозиторий.

# Выполнение

## Подготовка

В VMWare была установлена виртуальная машина с Fedora Linux 43 (Workstation Edition). Также были установлены необходимые утилиты командной строки:

```
sudo yum install -y wget rpmdevtools rpm-build createrepo yum-utils cmake gcc git nano
```

Репозиторий будет размещён локально с использованием Nginx, а содержать он будет Apache HTTP Server.

## Загрузка Apache HTTP Server и установка зависимостей

```
mkdir my_package && cd my_package
yumdownloader --source httpd
rpm -Uvh httpd*.src.rpm
yum-builddep httpd
```

## Сборка пакета

```
cd ~/rpmbuild/SPECS
rpmbuild -ba httpd.spec -D 'debug_package %{nil}'
```

Результат:

```
...
Requires: libc.so.6()(64bit) libc.so.6(GLIBC_2.14)(64bit) libc.so.6(GLIBC_2.2.5)(64bit) libc.so.6(GLIBC_2.3)(64bit) libc.so.6(GLIBC_2.3.4)(64bit) libc.so.6(GLIBC_2.38)(64bit) libc.so.6(GLIBC_2.4)(64bit) libc.so.6(GLIBC_ABI_DT_RELR)(64bit) libcrypt.so.2()(64bit) libcrypt.so.2(XCRYPT_2.0)(64bit) liblua-5.4.so()(64bit) libm.so.6()(64bit) rtld(GNU_HASH)
Checking for unpackaged file(s): /usr/lib/rpm/check-files /root/rpmbuild/BUILD/httpd-2.4.66-build/BUILDROOT
Wrote: /root/rpmbuild/SRPMS/httpd-2.4.66-1.fc43.src.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/mod_ssl-2.4.66-1.fc43.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/httpd-tools-2.4.66-1.fc43.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/httpd-devel-2.4.66-1.fc43.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/mod_ldap-2.4.66-1.fc43.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/mod_lua-2.4.66-1.fc43.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/mod_proxy_html-2.4.66-1.fc43.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/mod_session-2.4.66-1.fc43.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/noarch/httpd-filesystem-2.4.66-1.fc43.noarch.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/httpd-2.4.66-1.fc43.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/httpd-core-2.4.66-1.fc43.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/noarch/httpd-manual-2.4.66-1.fc43.noarch.rpm
Executing(rmbuild): /bin/sh -e /var/tmp/rpm-tmp.LL4z1P
+ umask 022
+ cd /root/rpmbuild/BUILD/httpd-2.4.66-build
+ test -d /root/rpmbuild/BUILD/httpd-2.4.66-build
+ /usr/bin/chmod -Rf a+rX,u+w,g-w,o-w /root/rpmbuild/BUILD/httpd-2.4.66-build
+ rm -rf /root/rpmbuild/BUILD/httpd-2.4.66-build
+ RPM_EC=0
++ jobs -p
+ exit 0
```

Проверим наличие пакетов с помощью `ls ~/rpmbuild/RPMS/x86_64`:

```
httpd-2.4.66-1.fc43.x86_64.rpm        httpd-tools-2.4.66-1.fc43.x86_64.rpm  mod_proxy_html-2.4.66-1.fc43.x86_64.rpm
httpd-core-2.4.66-1.fc43.x86_64.rpm   mod_ldap-2.4.66-1.fc43.x86_64.rpm     mod_session-2.4.66-1.fc43.x86_64.rpm
httpd-devel-2.4.66-1.fc43.x86_64.rpm  mod_lua-2.4.66-1.fc43.x86_64.rpm      mod_ssl-2.4.66-1.fc43.x86_64.rpm
```

Пакеты собраны и готовы к публикации.

## Установка и запуск Nginx

Скачаем с официального сайта актуальную версию Nginx (на момент выполнения задания 1.29.6), распакуем и установим:

```
wget https://nginx.org/download/nginx-1.29.6.tar.gz
tar xvf nginx-1.29.6.tar.gz
cd nginx-1.29.6
./configure
make
make install
```

Nginx установился в `/usr/local/nginx`. Добавим для удобства использования ссылку на исполняемый файл в `/usr/local/bin`:

```
ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx
```

Запустим Nginx, позвав `nginx`.

## Создание репозитория

Создадим директорию `repo` в `/usr/local/nginx/html` и скопируем туда созданные ранее пакеты:

```
mkdir -p /usr/local/nginx/html/repo
cp ~/rpmbuild/RPMS/x86_64/* /usr/local/nginx/html/repo/
```

Создадим репозиторий в данной директории с помощью `createrepo /usr/local/nginx/html/repo/`:

```
Directory walk started
Directory walk done - 9 packages
Temporary output repo path: ./repo/.repodata/
Pool started (with 5 workers)
Pool finished
```

Добавим в `/usr/local/nginx/conf/nginx.conf` в раздел server индексацию:

```
index index.html index.htm;
autoindex on;
```

И перезапустим nginx с помощью `nginx -s reload`. Открыв в браузере `http://localhost/repo/`, можем видеть список наших файлов, доступных для загрузки.

Добавим информацию о репозитории с помощью `cat >> /etc/yum.repos.d/otus.repo << EOF` (утащим образец из методички):

```
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
```

Проверим, что репозиторий был распознан с помощью `yum repolist --enabled | grep otus`:

```
otus                                           otus-linux
```

И попробуем установить из него RPM-пакет (`yum install httpd-2.4.66-1.fc43.x86_64`):

```
Updating and loading repositories:

 otus-linux                                                                   100% |   2.3 MiB/s |   4.7 KiB |  00m00s

 Repositories loaded.

 Package "httpd-2.4.66-1.fc43.x86_64" is already installed.



 Nothing to do.
```

Пакет был установлен ранее из локального файла, и повторная установка не была осуществлена (что логично, это тот же пакет). Следовательно, репозиторий работает.
