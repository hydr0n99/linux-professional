# Работа с загрузчиком

## Цель

Научиться попадать в систему без пароля. Устанавливать систему с LVM и переименовывать в VG.

## Описание/Пошаговая инструкция выполнения домашнего задания:

1. Включить отображение меню Grub.
2. Попасть в систему без пароля несколькими способами.
3. Установить систему с LVM, после чего переименовать VG.

# Выполнение

## Подготовка

В VMWare была установлена виртуальная машина с Ubuntu 24.04, при установке была использована опция `Use LVM`.

## Включение отображения меню Grub

Подредактируем конфиг Grub (`sudo nano /etc/default/grub`), в результате чего он принимает следующий вид:

```
GRUB_DEFAULT=0
#GRUB_TIMEOUT_STYLE=hidden
GRUB_TIMEOUT=15
GRUB_DISTRIBUTOR=`( . /etc/os-release; echo ${NAME:-Ubuntu} ) 2>/dev/null || echo Ubuntu`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
```

Обновим конфигурацию Grub (`sudo update-grub`) и перезагрузимся. После перезапуска видим [меню Grub](./grub_menu.jpg).

## Попасть в систему без пароля

### init=/bin/bash

Находясь в меню Grub, по нажатию клавиши `e` открываем настройки, проматываем в самый низ и находим [там](./grub_edit.jpg) строку:

```
linux      /vmlinuz-6.17.0-22-generic root=/dev/mapper/ubuntu--vg-ubuntu--lv ro quiet splash $vt_handoff
```

Заменив `ro quiet splash $vt_handoff` на `rw init=/bin/bash`, нажимаем Ctrl+X и загружаемся в root-терминал. Кстати говоря, в методичке указано, что нужно просто добавить `init=/bin/bash`, но это не сработало, при перезагрузке был просто чёрный экран.

### Recovery Mode

Перезагрузив машину, в Grub выбираем пункт `Advanced options for Ubuntu`, а затем переходим в пункт с `recovery mode` в описании.
Идём в пункт `network`, включаем (вообще вроде включено по умолчанию, но на всякий случай делаем принудительно ещё раз), затем выбираем пункт `root` и жмём Enter (затем ещё раз, чтобы запустить непосредственно root-терминал).

## Переименование VG в системе, установленной с LVM

Проверим список доступных Volume Group с помощью `vgs`:

```
  VG        #PV #LV #SN Attr   VSize   VFree

    ubuntu-vg   1   1   0 wz--n- <23.00g    0
```

Переименуем VG с помощью `vgrename ubuntu-vg my-beautiful-vg`. Результат:

```
Volume group "ubuntu-vg" successfully renamed to "my-beautiful-vg"
```

Затем правим `/boot/grub/grub.cfg`, заменяя все `ubuntu--vg` на `my--beautiful--vg`, сохраняем и перезагружаемся.

После перезагрузки (система запустилась, что свидетельствует об успехе) с помощью `vgs` видим, что название VG изменилось:

```
  VG              #PV #LV #SN Attr   VSize   VFree
  my-beautiful-vg   1   1   0 wz--n- <23.00g    0
```
