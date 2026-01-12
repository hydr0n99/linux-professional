# Обновление ядра системы

## Цель

Научиться обновлять ядро в ОС Linux


## Описание/Пошаговая инструкция выполнения домашнего задания:

1. Запустите ВМ c Ubuntu.
2. Обновите ядро ОС на новейшую стабильную версию из mainline-репозитория.
3. Оформите отчет в README-файле в GitHub-репозитории.


# Выполненние

## 1. Текущая версия ядра

`uname -r`

Результат:

`6.14.0-37-generic`

## 2. Обновление ядра

### 2.1. Скачивание пакетов

Обновление происходит до версии v6.19-rc5

Посредством wget скачиваются отсюда amd64-пакеты https://kernel.ubuntu.com/mainline/v6.19-rc5/

```
wget https://kernel.ubuntu.com/mainline/v6.19-rc5/amd64/linux-headers-6.19.0-061900rc5-generic_6.19.0-061900rc5.202601120354_amd64.deb
wget https://kernel.ubuntu.com/mainline/v6.19-rc5/amd64/linux-headers-6.19.0-061900rc5_6.19.0-061900rc5.202601120354_all.deb
wget https://kernel.ubuntu.com/mainline/v6.19-rc5/amd64/linux-image-unsigned-6.19.0-061900rc5-generic_6.19.0-061900rc5.202601120354_amd64.deb
wget https://kernel.ubuntu.com/mainline/v6.19-rc5/amd64/linux-modules-6.19.0-061900rc5-generic_6.19.0-061900rc5.202601120354_amd64.deb
```

### 2.2. Установка пакетов

```
sudo dpkg -i *.deb
```

Результат:

```
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
Adding boot menu entry for UEFI Firmware Settings ...
done
```


### 2.3. Установка ядра по-умолчанию и перезагрузка

```
sudo grub-set-default 0
sudo reboot now
```

## 3. Проверка новой версии

`uname -r`

Результат:

`6.19.0-061900rc5-generic`
