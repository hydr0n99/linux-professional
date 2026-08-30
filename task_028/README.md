# Репликация MySQL

## Цель

Поработать с реаликацией MySQL.

## Описание/Пошаговая инструкция выполнения домашнего задания:

В материалах приложены ссылки на вагрант для репликации и дамп базы bet.dmp

Базу развернуть на мастере и настроить так, чтобы реплицировались таблицы:


* bookmaker
* competition
* market
* odds
* outcome


Настроить GTID репликацию. Варианты, которые принимаются к сдаче:

* рабочий вагрантафайл
* скрины или логи SHOW TABLES
* конфиги*

Пример в логе изменения строки и появления строки на реплике*

## Выполнение

В качестве хоста используется ВМ под управлением Ubuntu 24.04 с 24 ГБ RAM на борту и 6 ядрами, а также вложенной виртуализацией.

* [Vagrantfile](./Vagrantfile)
* [Ansible-playbook для provison](./ansible/provision.yml)
* [Hosts](./ansible/hosts), [файлы](./ansible/files), [шаблоны](./ansible/templates)

## Проверка

После развёртывания машин подключимся к MySQL на slave-хосте и проверим, что БД bet на месте и репликация работает:

```
mysql> SHOW REPLICA STATUS\G
*************************** 1. row ***************************
             Replica_IO_State: Waiting for source to send event
                  Source_Host: 192.168.56.150
                  Source_User: repl
                  Source_Port: 3306
                Connect_Retry: 60
              Source_Log_File: mysql-bin.000002
          Read_Source_Log_Pos: 120680
               Relay_Log_File: slave-relay-bin.000002
                Relay_Log_Pos: 420
        Relay_Source_Log_File: mysql-bin.000002
           Replica_IO_Running: Yes
          Replica_SQL_Running: Yes
...
```

На master-хосте добавим запись в таблицу `bookmaker`:

```
mysql> INSERT INTO bookmaker (bookmaker_name) VALUES ('replication-test');
Query OK, 1 row affected (0.01 sec)
```

И сразу проверим наличие новой записи в БД на slave-хосте:

```
mysql> SELECT * FROM bet.bookmaker;
+----+------------------+
| id | bookmaker_name   |
+----+------------------+
|  4 | betway           |
|  5 | bwin             |
|  6 | ladbrokes        |
|  7 | replication-test |
|  3 | unibet           |
+----+------------------+
5 rows in set (0.00 sec)
```

Также проверим логи:

```
SET @@SESSION.GTID_NEXT= 'd390a8a6-a4c6-11f1-b1f7-080027d5b092:41'/*!*/;
# at 759
#260830 23:18:02 server id 1  end_log_pos 835 CRC32 0x77ca1a78  Query   thread_id=15    exec_time=0     error_code=0
SET TIMESTAMP=1788131882/*!*/;
BEGIN
/*!*/;
# at 835
# at 867
#260830 23:18:02 server id 1  end_log_pos 867 CRC32 0xe092a20f  Intvar
SET INSERT_ID=7/*!*/;
#260830 23:18:02 server id 1  end_log_pos 1004 CRC32 0xdacf15cc         Query   thread_id=15    exec_time=0     error_code=0
use `bet`/*!*/;
SET TIMESTAMP=1788131882/*!*/;
INSERT INTO bookmaker (bookmaker_name) VALUES ('replication-test')
/*!*/;
# at 1004
#260830 23:18:02 server id 1  end_log_pos 1035 CRC32 0xb406da5a         Xid = 119
COMMIT/*!*/;
```

Видим, что транзакция на master-хосте также была применена и на slave-хосте.
