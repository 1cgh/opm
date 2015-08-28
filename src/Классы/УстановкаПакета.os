﻿#Использовать logos
#Использовать tempfiles

Перем Лог;
Перем мВременныйКаталогУстановки;

Процедура УстановитьПакетИзАрхива(Знач ИмяПакета) Экспорт
	
	ПутьУстановки = НайтиСоздатьКаталогУстановки(ИмяПакета);
	
	мВременныйКаталогУстановки = ВременныеФайлы.СоздатьКаталог();
	
	Попытка
		Лог.Отладка("Открываем архив пакета");
		ЧтениеПакета = Новый ЧтениеZipФайла;
		ЧтениеПакета.Открыть(ИмяПакета);
		
		ФайлСодержимого = ИзвлечьОбязательныйФайл(ЧтениеПакета, Константы.ИмяФайлаСодержимогоПакета);
		ФайлМетаданных  = ИзвлечьОбязательныйФайл(ЧтениеПакета, Константы.ИмяФайлаМетаданныхПакета);
		
		Метаданные = ПрочитатьМетаданныеПакета(ФайлМетаданных);
		
		РазрешитьЗависимостиПакета(Метаданные);
		
		СтандартнаяОбработка = Истина;
		УстановитьФайлыПакета(ПутьУстановки, ФайлСодержимого, СтандартнаяОбработка);
		Если СтандартнаяОбработка Тогда
			СгенерироватьСкриптыЗапускаПриложенийПриНеобходимости(ПутьУстановки.ПолноеИмя, Метаданные);
		КонецЕсли;
		
		ЧтениеПакета.Закрыть();
		
		ВременныеФайлы.УдалитьФайл(мВременныйКаталогУстановки);
		
	Исключение
		ЧтениеПакета.Закрыть();
		ВременныеФайлы.УдалитьФайл(мВременныйКаталогУстановки);
		ВызватьИсключение;
	КонецПопытки;
	
	Лог.Отладка("Установка завершена");
	
КонецПроцедуры

Функция НайтиСоздатьКаталогУстановки(Знач ИмяПакета)
	
	СистемныеБиблиотеки = КаталогСистемныхБиблиотек();
	ФайлАрхива = Новый Файл(ИмяПакета);
	ИдентификаторПакета = ФайлАрхива.ИмяБезРасширения;
	
	ПутьУстановки = Новый Файл(ОбъединитьПути(СистемныеБиблиотеки, ИдентификаторПакета));
	Лог.Отладка("Путь установки пакета: " + ПутьУстановки.ПолноеИмя);
	
	Если Не ПутьУстановки.Существует() Тогда
		СоздатьКаталог(ПутьУстановки.ПолноеИмя);
	ИначеЕсли ПутьУстановки.ЭтоФайл() Тогда
		ВызватьИсключение "Не удалось создать каталог " + ПутьУстановки.ПолноеИмя;
	КонецЕсли;
	
	Возврат ПутьУстановки;
	
КонецФункции

Процедура РазрешитьЗависимостиПакета(Знач Манифест)
	
	Зависимости = Манифест.Зависимости();
	Если Зависимости.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	УстановленныеПакеты = ПолучитьУстановленныеПакеты();
	
	Для Каждого Зависимость Из Зависимости Цикл
		
		УстановленныйПакет = УстановленныеПакеты.Найти(Зависимость.ИмяПакета, "ИмяПакета");
		Если УстановленныйПакет = Неопределено Тогда
			// скачать
			// определить зависимости и так по кругу
			УстановитьПакетИзОблака(Зависимость);
		Иначе
			// считаем, что версия всегда подходит
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьУстановленныеПакеты()
	
КонецФункции

Процедура УстановитьПакетИзОблака(Знач ОписаниеПакета)

	ВызватьИсключение "Не реализовано";
	url = "http://hub.oscript.io/download/" + ОписаниеПакета.ИмяПакета + "/" + ОписаниеПакета.Версия;

КонецПроцедуры

Функция РазобратьМаркерВерсии(Знач МаркерВерсии)
	
	Перем ИндексВерсии;
	
	Оператор = Лев(МаркерВерсии, 1);
	Если Оператор = "<" или Оператор = ">" Тогда
		ТестОператор = Сред(МаркерВерсии, 2, 1);
		Если ТестОператор = "=" Тогда
			ИндексВерсии = 3;
		Иначе
			ИндексВерсии = 2;
		КонецЕсли;
	ИначеЕсли Оператор = "=" Тогда
		ИндексВерсии = 2;
	ИначеЕсли Найти("0123456789", Оператор) > 0 Тогда
		ИндексВерсии = 1;
	Иначе
		ВызватьИсключение "Некорректно задан маркер версии";
	КонецЕсли;
	
	Если ИндексВерсии > 1 Тогда
		Оператор = Лев(МаркерВерсии, ИндексВерсии-1);
	Иначе
		Оператор = "";
	КонецЕсли;
	
	Версия = Сред(МаркерВерсии, ИндексВерсии);
	
	Возврат Новый Структура("Оператор,Версия", Оператор, Версия);
	
КонецФункции

Функция КаталогСистемныхБиблиотек()
	
	СистемныеБиблиотеки = ПолучитьЗначениеСистемнойНастройки("lib.system");
	Если СистемныеБиблиотеки = Неопределено Тогда
		ВызватьИсключение "Не определен каталог системных библиотек";
	КонецЕсли;
	
	Возврат СистемныеБиблиотеки;
	
КонецФункции

Процедура УстановитьФайлыПакета(Знач ПутьУстановки, Знач ФайлСодержимого, СтандартнаяОбработка)
	
	ЧтениеСодержимого = Новый ЧтениеZipФайла(ФайлСодержимого);
	Попытка	
		ИмяСкриптаУстановки = Константы.ИмяФайлаСкриптаУстановки;
		ЭлементСкриптаУстановки = ЧтениеСодержимого.Элементы.Найти(ИмяСкриптаУстановки);
		Если ЭлементСкриптаУстановки <> Неопределено Тогда
			Лог.Отладка("Найден скрипт установки пакета");
			
			ЧтениеСодержимого.Извлечь(ЭлементСкриптаУстановки, мВременныйКаталогУстановки, РежимВосстановленияПутейФайловZIP.НеВосстанавливать);
			Лог.Отладка("Компиляция скрипта установки пакета");
			ОбъектСкрипта = ЗагрузитьСценарий(ОбъединитьПути(мВременныйКаталогУстановки, ИмяСкриптаУстановки));
			
			ВызватьСобытиеПередУстановкой(ОбъектСкрипта, ЧтениеСодержимого, ПутьУстановки.ПолноеИмя, СтандартнаяОбработка);
			
			Если СтандартнаяОбработка Тогда
				
				Лог.Отладка("Устанавливаю файлы пакета из архива");
				ЧтениеСодержимого.ИзвлечьВсе(ПутьУстановки.ПолноеИмя);
				
				ВызватьСобытиеПриУстановке(ОбъектСкрипта, ПутьУстановки.ПолноеИмя, СтандартнаяОбработка);
				
			КонецЕсли;
		Иначе
			Лог.Отладка("Устанавливаю файлы пакета из архива");
			ЧтениеСодержимого.ИзвлечьВсе(ПутьУстановки.ПолноеИмя);
		КонецЕсли;
	Исключение
		ЧтениеСодержимого.Закрыть();
		ВызватьИсключение;
	КонецПопытки;
	
	ЧтениеСодержимого.Закрыть();
	
КонецПроцедуры

Процедура ВызватьСобытиеПередУстановкой(Знач ОбъектСкрипта, Знач АрхивПакета, Знач Каталог, СтандартнаяОбработка)
	Лог.Отладка("Вызываю событие ПередУстановкой");
	ОбъектСкрипта.ПередУстановкой(АрхивПакета, Каталог, СтандартнаяОбработка);
КонецПроцедуры

Процедура ВызватьСобытиеПриУстановке(Знач ОбъектСкрипта, Знач Каталог, СтандартнаяОбработка)
	Лог.Отладка("Вызываю событие ПриУстановке");
	ОбъектСкрипта.ПриУстановке(Каталог, СтандартнаяОбработка);
КонецПроцедуры

Процедура СгенерироватьСкриптыЗапускаПриложенийПриНеобходимости(Знач КаталогУстановки, Знач ОписаниеПакета)
	
	ИмяПакета = ОписаниеПакета.Свойства().Имя;
	
	Для Каждого ФайлПриложения Из ОписаниеПакета.ИсполняемыеФайлы() Цикл
	
		Лог.Отладка("Регистрация приложения: " + ФайлПриложения);
		
		ОбъектФайл = Новый Файл(ОбъединитьПути(КаталогУстановки, ФайлПриложения));
		
		Если Не ОбъектФайл.Существует() Тогда
			Лог.Ошибка("Файл приложения " + ОбъектФайл.ПолноеИмя + " не существует");
			ВызватьИсключение "Некорректные данные в метаданных пакета";
		КонецЕсли;

		Каталог = КаталогПрограммы();
		СИ = Новый СистемнаяИнформация();
		Если Найти(СИ.ВерсияОС, "Windows") > 0 Тогда
			ФайлЗапуска = Новый ЗаписьТекста(ОбъединитьПути(Каталог, ИмяПакета + ".bat"), "cp866");
			ФайлЗапуска.ЗаписатьСтроку("@echo off");
			ФайлЗапуска.ЗаписатьСтроку("oscript.exe """ + ОбъектФайл.ПолноеИмя + """ %*");
			ФайлЗапуска.Закрыть();
		Иначе
			// TODO: проверить
			ФайлЗапуска = Новый ЗаписьТекста(ОбъединитьПути(Каталог, ИмяПакета));
			ФайлЗапуска.ЗаписатьСтроку("#!/bin/bash");
			ФайлЗапуска.ЗаписатьСтроку("/usr/bin/oscript """ + ОбъектФайл.ПолноеИмя + " $@""");
			ФайлЗапуска.Закрыть();
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПрочитатьМетаданныеПакета(Знач ФайлМетаданных)
	
	Перем Метаданные;
	
	Попытка
		Чтение = Новый ЧтениеXML;
		Чтение.ОткрытьФайл(ФайлМетаданных);
		
		Сериализатор = Новый СериализацияМетаданныхПакета;
		Метаданные = Сериализатор.ПрочитатьXML(Чтение);
		
		Чтение.Закрыть();
	Исключение
		Чтение.Закрыть();
		ВызватьИсключение;
	КонецПопытки;
	
	Возврат Метаданные;
	
КонецФункции

//////////////////////////////////////////////////////////////////////////////////
//

Функция ИзвлечьОбязательныйФайл(Знач Чтение, Знач ИмяФайла)
	Элемент = Чтение.Элементы.Найти(ИмяФайла);
	Если Элемент = Неопределено Тогда
		ВызватьИсключение "Неверная структура пакета. Не найден файл " + ИмяФайла;
	КонецЕсли;
	
	Чтение.Извлечь(Элемент, мВременныйКаталогУстановки);
	
	Возврат ОбъединитьПути(мВременныйКаталогУстановки, ИмяФайла);
	
КонецФункции

Лог = Логирование.ПолучитьЛог("oscript.app.opm");