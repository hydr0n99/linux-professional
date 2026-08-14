# VPN

## Цель

Создать домашнюю сетевую лабораторию. Научится настраивать VPN-сервер в Linux-based системах.

## Описание/Пошаговая инструкция выполнения домашнего задания:

Что нужно сделать?

1. Настроить VPN между двумя ВМ в tun/tap режимах, замерить скорость в туннелях, сделать вывод об отличающихся показателях

2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на ВМ

## Выполнение

В качестве хоста используется ВМ под управлением Ubuntu 24.04 с 24 ГБ RAM на борту и вложенной виртуализацией.

* [Vagrantfile](./Vagrantfile)
* [Ansible-playbook для VPN](./ansible/provision-vpn.yml) и [Ansible-playbook для RAS](./ansible/provision-ras.yml)
* [Вспомогательные файлы](./ansible/templates)

Настройка TUN/TAP режимов работы производится посредством определения значения переменной `vpn_mode` в [provison-vpn.yml](./ansible/provision-vpn.yml).

Плейбуки, соответствующие пунктам задания, выполняются в зависимости от того, задана ли в [Vagrantfile](./Vagrantfile) клиентская машина. Если задана, то выполняется плейбук, соответствующий 1-му пункту, если нет - то 2-му пункту. Во втором случае при осуществлении provision будет запрошен пароль для выполнения sudo-операций на хостовой машине.

## Сравнение TUN/TAP

### TAP

Данные клиента `iperf3`:

```
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-5.00   sec  23.4 MBytes  39.2 Mbits/sec   58    117 KBytes       
[  5]   5.00-10.00  sec  21.1 MBytes  35.3 Mbits/sec    0    207 KBytes       
[  5]  10.00-15.00  sec  23.3 MBytes  39.1 Mbits/sec    8    230 KBytes       
[  5]  15.00-20.00  sec  23.0 MBytes  38.5 Mbits/sec    9    181 KBytes       
[  5]  20.00-25.00  sec  22.8 MBytes  38.3 Mbits/sec    4    195 KBytes       
[  5]  25.00-30.00  sec  21.1 MBytes  35.4 Mbits/sec   10    218 KBytes       
[  5]  30.00-35.00  sec  20.6 MBytes  34.6 Mbits/sec   12    178 KBytes       
[  5]  35.00-40.00  sec  22.5 MBytes  37.7 Mbits/sec   24    204 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-40.00  sec   178 MBytes  37.3 Mbits/sec  125             sender
[  5]   0.00-40.03  sec   177 MBytes  37.1 Mbits/sec                  receiver
```

Данные сервера `iperf3`:

```
[ ID] Interval           Transfer     Bitrate
[  6]   0.00-1.00   sec  4.15 MBytes  34.8 Mbits/sec                  
[  6]   1.00-2.00   sec  4.75 MBytes  39.9 Mbits/sec                  
[  6]   2.00-3.01   sec  4.55 MBytes  37.9 Mbits/sec                  
[  6]   3.01-4.05   sec  4.78 MBytes  38.4 Mbits/sec                  
[  6]   4.05-5.00   sec  4.37 MBytes  38.6 Mbits/sec                  
[  6]   5.00-6.00   sec  4.41 MBytes  37.0 Mbits/sec                  
[  6]   6.00-7.00   sec  4.02 MBytes  33.7 Mbits/sec                  
[  6]   7.00-8.00   sec  3.71 MBytes  31.1 Mbits/sec                  
[  6]   8.00-9.00   sec  3.98 MBytes  33.4 Mbits/sec                  
[  6]   9.00-10.04  sec  4.91 MBytes  39.7 Mbits/sec                  
[  6]  10.04-11.00  sec  4.52 MBytes  39.4 Mbits/sec                  
[  6]  11.00-12.00  sec  4.50 MBytes  37.8 Mbits/sec                  
[  6]  12.00-13.01  sec  4.74 MBytes  39.4 Mbits/sec                  
[  6]  13.01-14.05  sec  4.85 MBytes  39.0 Mbits/sec                  
[  6]  14.05-15.00  sec  4.57 MBytes  40.4 Mbits/sec                  
[  6]  15.00-16.00  sec  4.60 MBytes  38.6 Mbits/sec                  
[  6]  16.00-17.03  sec  4.61 MBytes  37.4 Mbits/sec                  
[  6]  17.03-18.00  sec  4.54 MBytes  39.4 Mbits/sec                  
[  6]  18.00-19.00  sec  4.38 MBytes  36.8 Mbits/sec                  
[  6]  19.00-20.02  sec  4.65 MBytes  38.3 Mbits/sec                  
[  6]  20.02-21.00  sec  4.68 MBytes  40.0 Mbits/sec                  
[  6]  21.00-22.00  sec  4.46 MBytes  37.4 Mbits/sec                  
[  6]  22.00-23.01  sec  4.62 MBytes  38.3 Mbits/sec                  
[  6]  23.01-24.04  sec  4.73 MBytes  38.6 Mbits/sec                  
[  6]  24.04-25.00  sec  4.79 MBytes  41.9 Mbits/sec                  
[  6]  25.00-26.00  sec  3.13 MBytes  26.2 Mbits/sec                  
[  6]  26.00-27.00  sec  4.18 MBytes  35.1 Mbits/sec                  
[  6]  27.00-28.00  sec  4.46 MBytes  37.4 Mbits/sec                  
[  6]  28.00-29.00  sec  4.57 MBytes  38.2 Mbits/sec                  
[  6]  29.00-30.03  sec  4.75 MBytes  38.6 Mbits/sec                  
[  6]  30.03-31.00  sec  4.58 MBytes  39.7 Mbits/sec                  
[  6]  31.00-32.00  sec  3.94 MBytes  33.1 Mbits/sec                  
[  6]  32.00-33.00  sec  3.75 MBytes  31.5 Mbits/sec                  
[  6]  33.00-34.03  sec  4.05 MBytes  33.1 Mbits/sec                  
[  6]  34.03-35.00  sec  4.31 MBytes  37.1 Mbits/sec                  
[  6]  35.00-36.00  sec  4.11 MBytes  34.4 Mbits/sec                  
[  6]  36.00-37.02  sec  4.51 MBytes  37.2 Mbits/sec                  
[  6]  37.02-38.00  sec  4.71 MBytes  40.1 Mbits/sec                  
[  6]  38.00-39.00  sec  4.37 MBytes  36.6 Mbits/sec                  
[  6]  39.00-40.03  sec  4.56 MBytes  37.0 Mbits/sec                  
[  6]  40.03-40.03  sec  10.3 KBytes   191 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  6]   0.00-40.03  sec   177 MBytes  37.1 Mbits/sec                  receiver
```

### TUN

Данные клиента `iperf3`:

```
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-5.00   sec  24.2 MBytes  40.6 Mbits/sec   21    351 KBytes       
[  5]   5.00-10.00  sec  23.8 MBytes  40.0 Mbits/sec    5    304 KBytes       
[  5]  10.00-15.00  sec  23.8 MBytes  39.9 Mbits/sec   17    309 KBytes       
[  5]  15.00-20.01  sec  23.2 MBytes  38.9 Mbits/sec    1    277 KBytes       
[  5]  20.01-25.00  sec  23.2 MBytes  39.0 Mbits/sec   22    172 KBytes       
[  5]  25.00-30.00  sec  21.7 MBytes  36.4 Mbits/sec    0    246 KBytes       
[  5]  30.00-35.00  sec  23.2 MBytes  39.0 Mbits/sec    3    200 KBytes       
[  5]  35.00-40.00  sec  21.0 MBytes  35.2 Mbits/sec    9    206 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-40.00  sec   184 MBytes  38.6 Mbits/sec   78             sender
[  5]   0.00-40.00  sec   183 MBytes  38.4 Mbits/sec                  receiver
```

Данные сервера `iperf3`:

```
[ ID] Interval           Transfer     Bitrate
[  6]   0.00-1.00   sec  3.55 MBytes  29.8 Mbits/sec                  
[  6]   1.00-2.00   sec  4.39 MBytes  36.8 Mbits/sec                  
[  6]   2.00-3.00   sec  5.05 MBytes  42.4 Mbits/sec                  
[  6]   3.00-4.00   sec  4.86 MBytes  40.8 Mbits/sec                  
[  6]   4.00-5.04   sec  4.91 MBytes  39.5 Mbits/sec                  
[  6]   5.04-6.00   sec  4.67 MBytes  40.9 Mbits/sec                  
[  6]   6.00-7.00   sec  4.78 MBytes  40.1 Mbits/sec                  
[  6]   7.00-8.01   sec  4.83 MBytes  40.1 Mbits/sec                  
[  6]   8.01-9.04   sec  4.95 MBytes  40.5 Mbits/sec                  
[  6]   9.04-10.00  sec  4.67 MBytes  40.7 Mbits/sec                  
[  6]  10.00-11.00  sec  4.76 MBytes  39.9 Mbits/sec                  
[  6]  11.00-12.03  sec  4.78 MBytes  39.1 Mbits/sec                  
[  6]  12.03-13.00  sec  4.40 MBytes  37.9 Mbits/sec                  
[  6]  13.00-14.02  sec  4.87 MBytes  39.9 Mbits/sec                  
[  6]  14.02-15.00  sec  4.92 MBytes  42.2 Mbits/sec                  
[  6]  15.00-16.00  sec  4.69 MBytes  39.3 Mbits/sec                  
[  6]  16.00-17.04  sec  4.50 MBytes  36.4 Mbits/sec                  
[  6]  17.04-18.00  sec  4.72 MBytes  41.1 Mbits/sec                  
[  6]  18.00-19.00  sec  4.71 MBytes  39.5 Mbits/sec                  
[  6]  19.00-20.02  sec  4.74 MBytes  39.2 Mbits/sec                  
[  6]  20.02-21.00  sec  4.73 MBytes  40.3 Mbits/sec                  
[  6]  21.00-22.02  sec  4.05 MBytes  33.2 Mbits/sec                  
[  6]  22.02-23.00  sec  4.73 MBytes  40.7 Mbits/sec                  
[  6]  23.00-24.00  sec  4.76 MBytes  40.0 Mbits/sec                  
[  6]  24.00-25.02  sec  4.83 MBytes  39.8 Mbits/sec                  
[  6]  25.02-26.00  sec  4.46 MBytes  38.1 Mbits/sec                  
[  6]  26.00-27.00  sec  4.31 MBytes  36.2 Mbits/sec                  
[  6]  27.00-28.00  sec  4.12 MBytes  34.6 Mbits/sec                  
[  6]  28.00-29.00  sec  4.33 MBytes  36.4 Mbits/sec                  
[  6]  29.00-30.00  sec  4.25 MBytes  35.5 Mbits/sec                  
[  6]  30.00-31.02  sec  4.47 MBytes  36.9 Mbits/sec                  
[  6]  31.02-32.05  sec  4.62 MBytes  37.5 Mbits/sec                  
[  6]  32.05-33.00  sec  4.80 MBytes  42.6 Mbits/sec                  
[  6]  33.00-34.00  sec  4.68 MBytes  39.3 Mbits/sec                  
[  6]  34.00-35.00  sec  4.63 MBytes  38.8 Mbits/sec                  
[  6]  35.00-36.00  sec  3.71 MBytes  31.1 Mbits/sec                  
[  6]  36.00-37.00  sec  3.72 MBytes  31.2 Mbits/sec                  
[  6]  37.00-38.01  sec  4.60 MBytes  38.1 Mbits/sec                  
[  6]  38.01-39.00  sec  4.73 MBytes  40.2 Mbits/sec                  
[  6]  39.00-40.00  sec  4.64 MBytes  38.9 Mbits/sec                  
[  6]  40.00-40.00  sec  7.89 KBytes  60.6 Mbits/sec                  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  6]   0.00-40.00  sec   183 MBytes  38.4 Mbits/sec                  receiver
```

### Выводы

По результатам тестирования в режиме TUN пропускная способность составила 38,4 Мбит/с против 37,1 Мбит/с в режиме TAP, т.е. разница в считанные проценты. Количество повторных передач уменьшилось со 125 до 78. Это, вероятно, можно объяснить тем, что TUN работает на сетевом уровне и передаёт только IP-пакеты, тогда как TAP переносит полноценные Ethernet-кадры. Поэтому для обычного маршрутизируемого VPN режим TUN, судя по всему, предпочтительнее. Хотя учитывая возможные побочные эффекты (вроде различающейся загрузки процессора во время выполнения замеров), можно предположить, что реальная разница на уровне погрешности. Для более точных выводов нужно проводить многократные замеры.