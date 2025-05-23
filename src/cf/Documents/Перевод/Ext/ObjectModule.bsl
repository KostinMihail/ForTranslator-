﻿
#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	КоличествоСимволов = СтрДлина(Текст);
	Если Пользователь.Пустая() Тогда
		Пользователь = Пользователи.ТекущийПользователь();
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.ПланыПереводов.Записывать = Истина;
	Движение = Движения.ПланыПереводов.Добавить();
	Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
	Движение.Период = Дата;
	Движение.ПериодПлана = НачалоДня(Дата);
	Движение.Пользователь = Пользователь;
	Движение.Произведение = Произведение;
	Движение.План = КоличествоСимволов;
	Движения.Записать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Перевод.Дата КАК Дата,
		|	ПРЕДСТАВЛЕНИЕССЫЛКИ(Перевод.Пользователь) КАК Пользователь,
		|	ПРЕДСТАВЛЕНИЕССЫЛКИ(Перевод.Произведение) КАК Произведение,
		|	Перевод.КоличествоСимволов КАК КоличествоСимволов,
		|	ЕСТЬNULL(ПланыПереводовОстатки.ПланОстаток, 0) КАК План,
		|	ЕСТЬNULL(ПланыПереводовОстатки.ПланОстаток, 0) - Перевод.КоличествоСимволов КАК Осталось
		|ИЗ
		|	Документ.Перевод КАК Перевод
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ПланыПереводов.Остатки(
		|				,
		|				(ПериодПлана, Пользователь, Произведение) В
		|					(ВЫБРАТЬ
		|						НАЧАЛОПЕРИОДА(Перевод.Дата, ДЕНЬ) КАК ПериодПлана,
		|						Перевод.Пользователь КАК Пользователь,
		|						Перевод.Произведение КАК Произведение
		|					ИЗ
		|						Документ.Перевод КАК Перевод
		|					ГДЕ
		|						Перевод.Ссылка = &Ссылка)) КАК ПланыПереводовОстатки
		|		ПО (НАЧАЛОПЕРИОДА(Перевод.Дата, ДЕНЬ) = ПланыПереводовОстатки.ПериодПлана)
		|			И Перевод.Пользователь = ПланыПереводовОстатки.Пользователь
		|			И Перевод.Произведение = ПланыПереводовОстатки.Произведение
		|ГДЕ
		|	Перевод.Ссылка = &Ссылка
		|	И ЕСТЬNULL(ПланыПереводовОстатки.ПланОстаток, 0) - Перевод.КоличествоСимволов > 0";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		ШаблонСообщения = нСтр("ru='По произведению %1 для выполнения плана %2
			|от %3 необходимо перевести еще %4 символов'", "ru");
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = СтрШаблон(ШаблонСообщения,
							Выборка.Произведение,
							Выборка.План,
							Формат(Выборка.Дата, "ДФ=dd.MM.yyyy"),
							Выборка.Осталось);
		Сообщение.Поле = НСтр("ru = 'КоличествоСимволов'", "ru");
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
		Отказ = Истина;
		
	КонецЦикла;

	
КонецПроцедуры

#КонецОбласти
