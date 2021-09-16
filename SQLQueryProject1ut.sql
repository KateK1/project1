﻿---Количество договров и площади. Распределение по субъектам
Create view РаспределениеПо_Субъектам as
select TOP 10 Субъект, count(Договор) AS КоличествоДоговоров, SUM ([Общ S м2]) AS СуммарнаяПлощадь, ROUND(AVG ([Общ S м2]),0) AS СредняяПлощадь
from PortfolioProject1..Adresses
where Субъект is not NULL
group by Субъект
order by СуммарнаяПлощадь DESC

---Количество договров и площади. Распределение по населенным пунктам
Create view РаспределениеНаселенныеПункты as
select TOP 10 [Населенный пункт], count(Договор) AS КоличествоДоговоров, SUM ([Общ S м2]) AS СуммарнаяПлощадь, ROUND(AVG ([Общ S м2]),0) AS СредняяПлощадь
from PortfolioProject1..Adresses
where [Населенный пункт] is not NULL
group by [Населенный пункт]
order by КоличествоДоговоров DESC

--Количество оригинальных субъектов и населенных пунктов
Create view СубъектыНаселенныеПункты as
select  count(distinct Субъект) as Субъекты, count(distinct [Населенный пункт]) as НаселенныеПункты
from PortfolioProject1..Adresses
where [Населенный пункт] is not NULL
and Субъект is not NULL


--Суммы площади по видам+++
Create table pvt
(Год nvarchar(255),
Трава numeric,
БРП numeric,
Напыление numeric,
ЭПДМ numeric,
Рулонное numeric)

Insert into pvt
select DATEPART(year, [Дата Дог#]) as Год,
SUM ([ОбщS Трава]) AS Трава,
SUM (ISNULL(БРП10,0)) + SUM (ISNULL(БРП15,0))+ SUM(ISNULL(БРП20,0))+ SUM(ISNULL(БРП25,0))+SUM(ISNULL(БРП30,0))+SUM(ISNULL(БРП40,0))+ SUM(ISNULL([БРП 55],0)) AS аБРП,
SUM(ISNULL([БРП напыл 8+2],0)) + SUM(ISNULL([БРП напыл 10+2],0)) + SUM(ISNULL([БРП напыл 10+3],0)) AS СуммаНапыление,
SUM(ISNULL([ЭПДМ10+5],0)) + SUM(ISNULL([ЭПДМ 15+5],0)) + SUM(ISNULL([ЭПДМ 20+5],0)) + SUM(ISNULL([ЭПДМ 25+5],0)) + SUM(ISNULL([ЭПДМ 30+10],0)) + SUM(ISNULL([ЭПДМ 40+10],0)) + SUM(ISNULL([ЭПДМ 40+5],0)) AS ЭПДМ,
SUM (Рулонное) AS Рулонное
from PortfolioProject1..Types_Colors
where [Дата Дог#] is not NULL
group by DATEPART(year, [Дата Дог#])
Create view ПлощадиПоВидам as
SELECT Год, Категория, Количество
FROM   
   (SELECT Год, Трава, БРП, Напыление, ЭПДМ, Рулонное  
   FROM pvt) p
UNPIVOT  
	(Количество FOR Категория IN   
		(Трава, БРП, Напыление, ЭПДМ, Рулонное)  
)AS unpvt;
GO


--Распределение цветов покрытия БРП
select'Черный' AS Цвет, SUM([БРП черный]) AS Площадь
from PortfolioProject1..Types_Colors
union 
select 'Терракот' AS Цвет, SUM([БРП терракот]) AS Площадь
from PortfolioProject1..Types_Colors
union 
select 'Зеленый' AS Цвет, SUM([БРП зеленый]) AS Площадь
from PortfolioProject1..Types_Colors
union 
select 'Синий' AS Цвет, SUM([БРП синий]) AS Площадь
from PortfolioProject1..Types_Colors
union 
select 'Серый' AS Цвет, SUM([БРП серый]) AS Площадь
from PortfolioProject1..Types_Colors
union 
select 'Оранжевый' AS Цвет, SUM([БРП оранжевый]) AS Площадь
from PortfolioProject1..Types_Colors
union 
select 'Желтый' AS Цвет, SUM([БРП желтый]) AS Площадь
from PortfolioProject1..Types_Colors
where [Дата Дог#] is not NULL
order by Площадь desc


---ЭПДМ наростающий итог+++
Create view ЭПДМ_НаростающийИтог as
select convert(date,[Дата Дог#]) as Дата,
SUM([ЭПДМ зеленый]) OVER (order by [Дата Дог#]) AS Зеленый,
SUM([ЭПДМ терракот]) OVER (order by [Дата Дог#]) AS Терракот, 
SUM([ЭПДМ красный]) OVER (order by [Дата Дог#]) AS Красный, 
SUM([ЭПДМ желтый]) OVER (order by [Дата Дог#]) AS Желтый,
SUM([ЭПДМ синий]) OVER (order by [Дата Дог#]) AS Синий,
SUM([ЭПДМ белый]) OVER (order by [Дата Дог#]) AS Белый,
SUM([ЭПДМ оранжевый]) OVER (order by [Дата Дог#]) AS Оранжевый,
SUM([ЭПДМ серый]) OVER (order by [Дата Дог#]) AS Серый,
SUM([ЭПДМ бежевый]) OVER (order by [Дата Дог#]) AS Бежевый,
SUM([ЭПДМ голубой]) OVER (order by [Дата Дог#]) AS Голубой
from PortfolioProject1..Types_Colors
where [Дата Дог#] is not NULL
group by [Дата Дог#], [ЭПДМ зеленый], [ЭПДМ терракот], [ЭПДМ красный], [ЭПДМ желтый], [ЭПДМ синий], [ЭПДМ белый], [ЭПДМ оранжевый], [ЭПДМ серый], [ЭПДМ бежевый], [ЭПДМ голубой]



--Количество и процент вернувшихся клиентов
Create view РаспределениеКлиентов as
with ТаблицаПоКлиентам (Клиенты, ОригинальныеКлиенты, вернувшиесяКлиенты)
as
(
select count (ИНН) as Клиенты, cast(count (distinct ИНН) as float) as ОригинальныеКлиенты, cast((count (ИНН) - (count (distinct ИНН)))as float) as вернувшиесяКлиенты 
from PortfolioProject1..Main_info
where [Дата Дог#] is not NULL
)
select *, round(((вернувшиесяКлиенты/Клиенты)*100), 0) as ПроцентВернулись, round(((ОригинальныеКлиенты/Клиенты)*100), 0) ПроцентОриг
from ТаблицаПоКлиентам