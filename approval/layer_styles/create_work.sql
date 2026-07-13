-- Добавляем экстеншн постгиса
CREATE EXTENSION IF NOT EXISTS postgis;
-- Добавляем экстеншн для генерации гуидов
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- Добавляем МСК_77 систему координат
delete from spatial_ref_sys where srid = 980077;
INSERT into spatial_ref_sys (srid, auth_name, auth_srid, proj4text, srtext) 
VALUES ( 
980077, 
'MSK_77', 
980077, 
'+proj=tmerc +lat_0=55.66666666667 +lon_0=37.5 +k=1 +x_0=0 +y_0=0 +ellps=bessel +towgs84=458.475,0.244,603.087,-3.98169,-0.43293,4.43381,1.713 +units=m +no_defs',
'PROJCS["MSK_77",GEOGCS["unknown",DATUM["Unknown based on Bessel 1841 ellipsoid",SPHEROID["Bessel 1841",6377397.155,299.1528128],TOWGS84[458.475,0.244,603.087,-3.98169,-0.43293,4.43381,1.713]],PRIMEM["Greenwich",0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.0174532925199433,AUTHORITY["EPSG","9122"]]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",55.66666666667],PARAMETER["central_meridian",37.5],PARAMETER["scale_factor",1],PARAMETER["false_easting",0],PARAMETER["false_northing",0],UNIT["metre",1,AUTHORITY["EPSG","9001"]],AXIS["Easting",EAST],AXIS["Northing",NORTH]]'
) ON CONFLICT DO NOTHING;

CREATE SCHEMA IF NOT EXISTS "work";
GRANT ALL ON SCHEMA "work" TO postgres;
GRANT USAGE ON SCHEMA "work" TO mggt;
GRANT USAGE ON SCHEMA "work" TO mggt_editor;
GRANT USAGE ON SCHEMA "work" TO mggt_reader;
COMMENT ON SCHEMA "work" IS 'Схема для хранения рабочих (неутвержденных) данных';

-- ==== СОЗДАЁМ СЛОИ ВОРКА ====
-- Создаём таск ворка
CREATE TABLE IF NOT EXISTS "work"."task"(
    fid serial PRIMARY KEY NOT NULL,
    "TaskGUID" uuid NULL,
    "VALID" bool NULL,
	"CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "Geometry" geometry(MULTIPOLYGON, 980077) NULL);

CREATE INDEX IF NOT EXISTS "task_Geom_idx" ON "work"."task" USING gist ("Geometry");

ALTER TABLE "work"."task" OWNER to postgres;
GRANT ALL ON TABLE "work"."task" TO mggt;
GRANT ALL ON TABLE "work"."task" TO postgres;
GRANT ALL ON TABLE "work"."task" TO mggt_editor;
GRANT SELECT ON TABLE "work"."task" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."task_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."task_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."task_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."task_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."task" IS 'Таблица для редактирования геометрии задач';
COMMENT ON COLUMN "work"."task".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."task"."TaskGUID" IS 'Идентификатор задачи в рамках которого редактируется этот объект';
COMMENT ON COLUMN "work"."task"."VALID" IS 'Признак корректности границы задачи';
COMMENT ON COLUMN "work"."task"."CreateDate" IS 'Дата создания границы';
COMMENT ON COLUMN "work"."task"."CreateAuthor" IS 'Автор создания границы';
COMMENT ON COLUMN "work"."task"."ChangeDate" IS 'Дата последнего изменения границы';
COMMENT ON COLUMN "work"."task"."ChangeAuthor" IS 'Автор последнего изменения границы';
COMMENT ON COLUMN "work"."task"."Geometry" IS 'Геометрия области выполнения задачи';

-- Создаём слой для работы по участкам
CREATE TABLE IF NOT EXISTS "work"."WorkArea"(
    fid serial PRIMARY KEY NOT NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MULTIPOLYGON, 980077) NULL);

CREATE INDEX IF NOT EXISTS "WorkArea_Geom_idx" ON "work"."WorkArea" USING gist ("Geometry");

ALTER TABLE "work"."WorkArea" OWNER to postgres;
GRANT ALL ON TABLE "work"."WorkArea" TO mggt;
GRANT ALL ON TABLE "work"."WorkArea" TO postgres;
GRANT ALL ON TABLE "work"."WorkArea" TO mggt_editor;
GRANT SELECT ON TABLE "work"."WorkArea" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."WorkArea_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."WorkArea_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."WorkArea_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."WorkArea_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."WorkArea" IS 'Слой для работы по частям, а не по всей границе задачи';
COMMENT ON COLUMN "work"."WorkArea".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."WorkArea"."TaskGUID" IS 'Идентификатор задачи в рамках которого редактируется этот объект';
COMMENT ON COLUMN "work"."WorkArea"."Geometry" IS 'Геометрия области выполнения задачи';

-- Создаём Элементы сопряжения поверхностей
CREATE TABLE IF NOT EXISTS "work"."AbutmentLine"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "AbutmentType" text NULL,
    "Material" text NULL,
    "Distance" float8 NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "AbutmentLine_Geom_idx" ON "work"."AbutmentLine" USING gist ("Geometry");

ALTER TABLE "work"."AbutmentLine" OWNER to postgres;
GRANT ALL ON TABLE "work"."AbutmentLine" TO mggt;
GRANT ALL ON TABLE "work"."AbutmentLine" TO postgres;
GRANT ALL ON TABLE "work"."AbutmentLine" TO mggt_editor;
GRANT SELECT ON TABLE "work"."AbutmentLine" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."AbutmentLine_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."AbutmentLine_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."AbutmentLine_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."AbutmentLine_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."AbutmentLine" IS 'Элементы сопряжения поверхностей';
COMMENT ON COLUMN "work"."AbutmentLine".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."AbutmentLine"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."AbutmentLine"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."AbutmentLine"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."AbutmentLine"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."AbutmentLine"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."AbutmentLine"."AbutmentType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."AbutmentLine"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."AbutmentLine"."Distance" IS 'Длина/Расстояние';
COMMENT ON COLUMN "work"."AbutmentLine"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."AbutmentLine"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."AbutmentLine"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."AbutmentLine"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."AbutmentLine"."ParentRootId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."AbutmentLine"."ParentStartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."AbutmentLine"."ParentEndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."AbutmentLine"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."AbutmentLine"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."AbutmentLine"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."AbutmentLine"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."AbutmentLine"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."AbutmentLine"."Geometry" IS 'Геометрия объекта';


-- Создаём Бортовые камни
CREATE TABLE IF NOT EXISTS "work"."BoardStoneLine"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "FlatElementType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "Distance" float8 NULL,
    "BoundStoneMark" text NULL,
    "Material" text NULL,
    "IsGutterZone" bool NULL,
    "NearRoadway" bool NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "BoardStoneLine_Geom_idx" ON "work"."BoardStoneLine" USING gist ("Geometry");

ALTER TABLE "work"."BoardStoneLine" OWNER to postgres;
GRANT ALL ON TABLE "work"."BoardStoneLine" TO mggt;
GRANT ALL ON TABLE "work"."BoardStoneLine" TO postgres;
GRANT ALL ON TABLE "work"."BoardStoneLine" TO mggt_editor;
GRANT SELECT ON TABLE "work"."BoardStoneLine" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."BoardStoneLine_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."BoardStoneLine_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."BoardStoneLine_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."BoardStoneLine_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."BoardStoneLine" IS 'Бортовые камни';
COMMENT ON COLUMN "work"."BoardStoneLine".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."BoardStoneLine"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."BoardStoneLine"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."BoardStoneLine"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."BoardStoneLine"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."BoardStoneLine"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."BoardStoneLine"."FlatElementType" IS 'Код типа';
COMMENT ON COLUMN "work"."BoardStoneLine"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."BoardStoneLine"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."BoardStoneLine"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."BoardStoneLine"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."BoardStoneLine"."Distance" IS 'Длина, п.м';
COMMENT ON COLUMN "work"."BoardStoneLine"."BoundStoneMark" IS 'Код марки бортового камня';
COMMENT ON COLUMN "work"."BoardStoneLine"."Material" IS 'Материал бортового камня';
COMMENT ON COLUMN "work"."BoardStoneLine"."IsGutterZone" IS 'Признак лотковой зоны';
COMMENT ON COLUMN "work"."BoardStoneLine"."NearRoadway" IS 'Прилегает к проезжей части';
COMMENT ON COLUMN "work"."BoardStoneLine"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."BoardStoneLine"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."BoardStoneLine"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."BoardStoneLine"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."BoardStoneLine"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."BoardStoneLine"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."BoardStoneLine"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."BoardStoneLine"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."BoardStoneLine"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."BoardStoneLine"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."BoardStoneLine"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."BoardStoneLine"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."BoardStoneLine"."Geometry" IS 'Геометрия объекта';


-- Создаём Объект капитального строительства
CREATE TABLE IF NOT EXISTS "work"."BuildingPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "BuildingsType" text NULL,
    "BuildingsTypeSpec" text NULL,
    "Unom" int8 NULL,
    "Unad" int8 NULL,
    "BuildArea" float8 NULL,
    "FloorQty" int8 NULL,
    "Property" text NULL,
    "FileList" text NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "BuildingPoly_Geom_idx" ON "work"."BuildingPoly" USING gist ("Geometry");

ALTER TABLE "work"."BuildingPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."BuildingPoly" TO mggt;
GRANT ALL ON TABLE "work"."BuildingPoly" TO postgres;
GRANT ALL ON TABLE "work"."BuildingPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."BuildingPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."BuildingPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."BuildingPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."BuildingPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."BuildingPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."BuildingPoly" IS 'Объект капитального строительства';
COMMENT ON COLUMN "work"."BuildingPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."BuildingPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."BuildingPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."BuildingPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."BuildingPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."BuildingPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."BuildingPoly"."BuildingsType" IS 'Код назначения';
COMMENT ON COLUMN "work"."BuildingPoly"."BuildingsTypeSpec" IS 'Код уточнения назначения';
COMMENT ON COLUMN "work"."BuildingPoly"."Unom" IS 'Данные об УНОМ';
COMMENT ON COLUMN "work"."BuildingPoly"."Unad" IS 'Данные об УНАД';
COMMENT ON COLUMN "work"."BuildingPoly"."BuildArea" IS 'Площадь застройки, кв.м.';
COMMENT ON COLUMN "work"."BuildingPoly"."FloorQty" IS 'Этажность';
COMMENT ON COLUMN "work"."BuildingPoly"."Property" IS 'Характеристика';
COMMENT ON COLUMN "work"."BuildingPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."BuildingPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."BuildingPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."BuildingPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."BuildingPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."BuildingPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."BuildingPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."BuildingPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."BuildingPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."BuildingPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."BuildingPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."BuildingPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."BuildingPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Проезжие части
CREATE TABLE IF NOT EXISTS "work"."CarriagewayPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "FlatElementType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "CoatingType" text NULL,
    "CoatingGroup" text NULL,
    "Area" float8 NULL,
    "Distance" float8 NULL,
    "WidthBegin" float8 NULL,
    "WidthEnd" float8 NULL,
    "AutoCleanArea" float8 NULL,
    "ManualCleanArea" float8 NULL,
    "NoCleanArea" float8 NULL,
    "Description" text NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL,
    "AxisGeometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "CarriagewayPoly_Geom_idx" ON "work"."CarriagewayPoly" USING gist ("Geometry");
CREATE INDEX IF NOT EXISTS "CarriagewayPoly_AxisGeom_idx" ON "work"."CarriagewayPoly" USING gist ("AxisGeometry");

ALTER TABLE "work"."CarriagewayPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."CarriagewayPoly" TO mggt;
GRANT ALL ON TABLE "work"."CarriagewayPoly" TO postgres;
GRANT ALL ON TABLE "work"."CarriagewayPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."CarriagewayPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."CarriagewayPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."CarriagewayPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."CarriagewayPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."CarriagewayPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."CarriagewayPoly" IS 'Проезжие части';
COMMENT ON COLUMN "work"."CarriagewayPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."CarriagewayPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."CarriagewayPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."CarriagewayPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."CarriagewayPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."CarriagewayPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."CarriagewayPoly"."FlatElementType" IS 'Код типа проезжей части';
COMMENT ON COLUMN "work"."CarriagewayPoly"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."CarriagewayPoly"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."CarriagewayPoly"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."CarriagewayPoly"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."CarriagewayPoly"."CoatingType" IS 'Код наименования вида покрытия (Вид покрытия, уточнение)';
COMMENT ON COLUMN "work"."CarriagewayPoly"."CoatingGroup" IS 'Код группы покрытия (Вид покрытия)';
COMMENT ON COLUMN "work"."CarriagewayPoly"."Area" IS 'Площадь, кв. м.';
COMMENT ON COLUMN "work"."CarriagewayPoly"."Distance" IS 'Длина, п.м';
COMMENT ON COLUMN "work"."CarriagewayPoly"."WidthBegin" IS 'Ширина в начале, м';
COMMENT ON COLUMN "work"."CarriagewayPoly"."WidthEnd" IS 'Ширина в конце, м';
COMMENT ON COLUMN "work"."CarriagewayPoly"."AutoCleanArea" IS 'Площадь уборки мех., кв.м';
COMMENT ON COLUMN "work"."CarriagewayPoly"."ManualCleanArea" IS 'Площадь уборки ручн., кв.м';
COMMENT ON COLUMN "work"."CarriagewayPoly"."NoCleanArea" IS 'Площадь без уборки, кв.м';
COMMENT ON COLUMN "work"."CarriagewayPoly"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."CarriagewayPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."CarriagewayPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."CarriagewayPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."CarriagewayPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."CarriagewayPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."CarriagewayPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."CarriagewayPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."CarriagewayPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."CarriagewayPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."CarriagewayPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."CarriagewayPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."CarriagewayPoly"."Geometry" IS 'Геометрия объекта';
COMMENT ON COLUMN "work"."CarriagewayPoly"."AxisGeometry" IS 'Геометрия осевой линии объекта';


-- Создаём Места накопления отходов (Точка)
CREATE TABLE IF NOT EXISTS "work"."ContainerPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ContainerType" text NULL,
    "CoatingType" text NULL,
    "CoatingGroup" text NULL,
    "Unom" int8 NULL,
    "Unad" int8 NULL,
    "Area" float8 NULL,
    "AbutmentType" text NULL,
    "AbutmentDistance" int NULL,
    "MafsTypeList" text NULL,
    "IsSeparateGarbageCollection" bool NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "InYard" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "ContainerPoint_Geom_idx" ON "work"."ContainerPoint" USING gist ("Geometry");

ALTER TABLE "work"."ContainerPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."ContainerPoint" TO mggt;
GRANT ALL ON TABLE "work"."ContainerPoint" TO postgres;
GRANT ALL ON TABLE "work"."ContainerPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."ContainerPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."ContainerPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."ContainerPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."ContainerPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."ContainerPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."ContainerPoint" IS 'Места накопления отходов (Точка)';
COMMENT ON COLUMN "work"."ContainerPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."ContainerPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."ContainerPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."ContainerPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."ContainerPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."ContainerPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."ContainerPoint"."ContainerType" IS 'Код типа МСО';
COMMENT ON COLUMN "work"."ContainerPoint"."CoatingType" IS 'Код наименования вида покрытия (Вид покрытия, уточнение)';
COMMENT ON COLUMN "work"."ContainerPoint"."CoatingGroup" IS 'Код группы покрытия (Вид покрытия)';
COMMENT ON COLUMN "work"."ContainerPoint"."Unom" IS 'Данные UNOM';
COMMENT ON COLUMN "work"."ContainerPoint"."Unad" IS 'Данные UNAD';
COMMENT ON COLUMN "work"."ContainerPoint"."Area" IS 'Площадь, кв. м.';
COMMENT ON COLUMN "work"."ContainerPoint"."AbutmentType" IS 'Элемент сопряжения';
COMMENT ON COLUMN "work"."ContainerPoint"."AbutmentDistance" IS 'Количество, п.м.';
COMMENT ON COLUMN "work"."ContainerPoint"."MafsTypeList" IS 'МАФ';
COMMENT ON COLUMN "work"."ContainerPoint"."IsSeparateGarbageCollection" IS 'Признак раздельного сбора мусора';
COMMENT ON COLUMN "work"."ContainerPoint"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."ContainerPoint"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."ContainerPoint"."InYard" IS 'Признак «Внутридворовое»';
COMMENT ON COLUMN "work"."ContainerPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."ContainerPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."ContainerPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."ContainerPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."ContainerPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."ContainerPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."ContainerPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."ContainerPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."ContainerPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."ContainerPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."ContainerPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."ContainerPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Места накопления отходов (Полигон)
CREATE TABLE IF NOT EXISTS "work"."ContainerPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ContainerType" text NULL,
    "CoatingType" text NULL,
    "CoatingGroup" text NULL,
    "Unom" int8 NULL,
    "Unad" int8 NULL,
    "Area" float8 NULL,
    "AbutmentType" text NULL,
    "AbutmentDistance" int NULL,
    "MafsTypeList" text NULL,
    "IsSeparateGarbageCollection" bool NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "InYard" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "ContainerPoly_Geom_idx" ON "work"."ContainerPoly" USING gist ("Geometry");

ALTER TABLE "work"."ContainerPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."ContainerPoly" TO mggt;
GRANT ALL ON TABLE "work"."ContainerPoly" TO postgres;
GRANT ALL ON TABLE "work"."ContainerPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."ContainerPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."ContainerPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."ContainerPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."ContainerPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."ContainerPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."ContainerPoly" IS 'Места накопления отходов (Полигон)';
COMMENT ON COLUMN "work"."ContainerPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."ContainerPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."ContainerPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."ContainerPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."ContainerPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."ContainerPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."ContainerPoly"."ContainerType" IS 'Код типа МСО';
COMMENT ON COLUMN "work"."ContainerPoly"."CoatingType" IS 'Код наименования вида покрытия (Вид покрытия, уточнение)';
COMMENT ON COLUMN "work"."ContainerPoly"."CoatingGroup" IS 'Код группы покрытия (Вид покрытия)';
COMMENT ON COLUMN "work"."ContainerPoly"."Unom" IS 'Данные UNOM';
COMMENT ON COLUMN "work"."ContainerPoly"."Unad" IS 'Данные UNAD';
COMMENT ON COLUMN "work"."ContainerPoly"."Area" IS 'Площадь, кв. м.';
COMMENT ON COLUMN "work"."ContainerPoly"."AbutmentType" IS 'Элемент сопряжения';
COMMENT ON COLUMN "work"."ContainerPoly"."AbutmentDistance" IS 'Количество, п.м.';
COMMENT ON COLUMN "work"."ContainerPoly"."MafsTypeList" IS 'МАФ';
COMMENT ON COLUMN "work"."ContainerPoly"."IsSeparateGarbageCollection" IS 'Признак раздельного сбора мусора';
COMMENT ON COLUMN "work"."ContainerPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."ContainerPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."ContainerPoly"."InYard" IS 'Признак «Внутридворовое»';
COMMENT ON COLUMN "work"."ContainerPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."ContainerPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."ContainerPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."ContainerPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."ContainerPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."ContainerPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."ContainerPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."ContainerPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."ContainerPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."ContainerPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."ContainerPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."ContainerPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Дорожно-тропиночная сеть
CREATE TABLE IF NOT EXISTS "work"."DtsPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "DtsType" text NULL,
    "CoatingType" text NULL,
    "CoatingGroup" text NULL,
    "TotalArea" float8 NULL,
    "AutoCleanArea" float8 NULL,
    "ManualCleanArea" float8 NULL,
    "AbutmentTypeList" text NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsSmmCleaning" bool NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "DtsPoly_Geom_idx" ON "work"."DtsPoly" USING gist ("Geometry");

ALTER TABLE "work"."DtsPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."DtsPoly" TO mggt;
GRANT ALL ON TABLE "work"."DtsPoly" TO postgres;
GRANT ALL ON TABLE "work"."DtsPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."DtsPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."DtsPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."DtsPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."DtsPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."DtsPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."DtsPoly" IS 'Дорожно-тропиночная сеть';
COMMENT ON COLUMN "work"."DtsPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."DtsPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."DtsPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."DtsPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."DtsPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."DtsPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."DtsPoly"."DtsType" IS 'Код назначения';
COMMENT ON COLUMN "work"."DtsPoly"."CoatingType" IS 'Код наименования вида покрытия (Вид покрытия, уточнение)';
COMMENT ON COLUMN "work"."DtsPoly"."CoatingGroup" IS 'Код группы покрытия (Вид покрытия)';
COMMENT ON COLUMN "work"."DtsPoly"."TotalArea" IS 'Площадь кв.м';
COMMENT ON COLUMN "work"."DtsPoly"."AutoCleanArea" IS 'Площадь уборки мех., кв.м';
COMMENT ON COLUMN "work"."DtsPoly"."ManualCleanArea" IS 'Площадь уборки ручн., кв.м';
COMMENT ON COLUMN "work"."DtsPoly"."AbutmentTypeList" IS 'Элементы сопряжения';
COMMENT ON COLUMN "work"."DtsPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."DtsPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."DtsPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."DtsPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."DtsPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."DtsPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."DtsPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."DtsPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."DtsPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."DtsPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."DtsPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."DtsPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."DtsPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."DtsPoly"."IsSmmCleaning" IS 'Признак «Уборка с применением СММ»';
COMMENT ON COLUMN "work"."DtsPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Инженерные сооружения (Точка)
CREATE TABLE IF NOT EXISTS "work"."EngineerBuildingPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "EngineerBuildingType" text NULL,
    "Quantity" int8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "CoatingType" text NULL,
    "CoatingFaceType" text NULL,
    "FaceArea" float8 NULL,
    "CleanType" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsSmmCleaning" bool NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "EngineerBuildingPoint_Geom_idx" ON "work"."EngineerBuildingPoint" USING gist ("Geometry");

ALTER TABLE "work"."EngineerBuildingPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."EngineerBuildingPoint" TO mggt;
GRANT ALL ON TABLE "work"."EngineerBuildingPoint" TO postgres;
GRANT ALL ON TABLE "work"."EngineerBuildingPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."EngineerBuildingPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."EngineerBuildingPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."EngineerBuildingPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."EngineerBuildingPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."EngineerBuildingPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."EngineerBuildingPoint" IS 'Инженерные сооружения (Точка)';
COMMENT ON COLUMN "work"."EngineerBuildingPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."EngineerBuildingType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."CoatingType" IS 'Код вида покрытия (уточнение)';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."CoatingFaceType" IS 'Код вида покрытия (облицовка)';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."FaceArea" IS 'Площадь покрытия (облицовка), кв м.';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."CleanType" IS 'Тип уборки';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."ParentStartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."ParentEndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."IsSmmCleaning" IS 'Признак «Уборка с применением СММ»';
COMMENT ON COLUMN "work"."EngineerBuildingPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Инженерные сооружения (Полигон)
CREATE TABLE IF NOT EXISTS "work"."EngineerBuildingPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "EngineerBuildingType" text NULL,
    "Quantity" int8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "CoatingType" text NULL,
    "CoatingFaceType" text NULL,
    "FaceArea" float8 NULL,
    "CleanType" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsSmmCleaning" bool NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "EngineerBuildingPoly_Geom_idx" ON "work"."EngineerBuildingPoly" USING gist ("Geometry");

ALTER TABLE "work"."EngineerBuildingPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."EngineerBuildingPoly" TO mggt;
GRANT ALL ON TABLE "work"."EngineerBuildingPoly" TO postgres;
GRANT ALL ON TABLE "work"."EngineerBuildingPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."EngineerBuildingPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."EngineerBuildingPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."EngineerBuildingPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."EngineerBuildingPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."EngineerBuildingPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."EngineerBuildingPoly" IS 'Инженерные сооружения (Полигон)';
COMMENT ON COLUMN "work"."EngineerBuildingPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."EngineerBuildingType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."CoatingType" IS 'Код вида покрытия (уточнение)';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."CoatingFaceType" IS 'Код вида покрытия (облицовка)';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."FaceArea" IS 'Площадь покрытия (облицовка), кв м.';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."CleanType" IS 'Тип уборки';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."ParentStartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."ParentEndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."IsSmmCleaning" IS 'Признак «Уборка с применением СММ»';
COMMENT ON COLUMN "work"."EngineerBuildingPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Ограждения (Линия)
CREATE TABLE IF NOT EXISTS "work"."FencingLine"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "EquipmentKind" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "QuantityRm" float8 NULL,
    "QuantityPcs" float8 NULL,
    "Area" float8 NULL,
    "GuttersLength" float8 NULL,
    -- Удалено в новой версии
    -- "Placement" text NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "FencingLine_Geom_idx" ON "work"."FencingLine" USING gist ("Geometry");

ALTER TABLE "work"."FencingLine" OWNER to postgres;
GRANT ALL ON TABLE "work"."FencingLine" TO mggt;
GRANT ALL ON TABLE "work"."FencingLine" TO postgres;
GRANT ALL ON TABLE "work"."FencingLine" TO mggt_editor;
GRANT SELECT ON TABLE "work"."FencingLine" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."FencingLine_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."FencingLine_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."FencingLine_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."FencingLine_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."FencingLine" IS 'Ограждения (Линия)';
COMMENT ON COLUMN "work"."FencingLine".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."FencingLine"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."FencingLine"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."FencingLine"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."FencingLine"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."FencingLine"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."FencingLine"."EquipmentKind" IS 'Код типа ограждения';
COMMENT ON COLUMN "work"."FencingLine"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."FencingLine"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."FencingLine"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."FencingLine"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."FencingLine"."QuantityRm" IS 'Протяженность, п.м';
COMMENT ON COLUMN "work"."FencingLine"."QuantityPcs" IS 'Количество, шт.';
COMMENT ON COLUMN "work"."FencingLine"."Area" IS 'Площадь, кв.м';
COMMENT ON COLUMN "work"."FencingLine"."GuttersLength" IS 'Двухметровая прилотковая зона, п.м.';
-- Удалено в новой версии
-- COMMENT ON COLUMN "work"."FencingLine"."Placement" IS 'Код места размещения';
COMMENT ON COLUMN "work"."FencingLine"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."FencingLine"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."FencingLine"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."FencingLine"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."FencingLine"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."FencingLine"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."FencingLine"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."FencingLine"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."FencingLine"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."FencingLine"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."FencingLine"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."FencingLine"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."FencingLine"."Geometry" IS 'Геометрия объекта';


-- Создаём Ограждения (Точка)
CREATE TABLE IF NOT EXISTS "work"."FencingPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "EquipmentKind" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "QuantityRm" float8 NULL,
    "QuantityPcs" float8 NULL,
    "Area" float8 NULL,
    "GuttersLength" float8 NULL,
    -- Удалено в новой версии
    -- "Placement" text NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "FencingPoint_Geom_idx" ON "work"."FencingPoint" USING gist ("Geometry");

ALTER TABLE "work"."FencingPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."FencingPoint" TO mggt;
GRANT ALL ON TABLE "work"."FencingPoint" TO postgres;
GRANT ALL ON TABLE "work"."FencingPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."FencingPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."FencingPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."FencingPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."FencingPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."FencingPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."FencingPoint" IS 'Ограждения (Точка)';
COMMENT ON COLUMN "work"."FencingPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."FencingPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."FencingPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."FencingPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."FencingPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."FencingPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."FencingPoint"."EquipmentKind" IS 'Код типа ограждения';
COMMENT ON COLUMN "work"."FencingPoint"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."FencingPoint"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."FencingPoint"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."FencingPoint"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."FencingPoint"."QuantityRm" IS 'Протяженность, п.м';
COMMENT ON COLUMN "work"."FencingPoint"."QuantityPcs" IS 'Количество, шт.';
COMMENT ON COLUMN "work"."FencingPoint"."Area" IS 'Площадь, кв.м';
COMMENT ON COLUMN "work"."FencingPoint"."GuttersLength" IS 'Двухметровая прилотковая зона, п.м.';
-- Удалено в новой версии
-- COMMENT ON COLUMN "work"."FencingPoint"."Placement" IS 'Код места размещения';
COMMENT ON COLUMN "work"."FencingPoint"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."FencingPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."FencingPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."FencingPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."FencingPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."FencingPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."FencingPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."FencingPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."FencingPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."FencingPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."FencingPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."FencingPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."FencingPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Ограждения (Точка)
CREATE TABLE IF NOT EXISTS "work"."FencingPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "EquipmentKind" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "QuantityRm" float8 NULL,
    "QuantityPcs" float8 NULL,
    "Area" float8 NULL,
    "GuttersLength" float8 NULL,
    -- Удалено в новой версии
    -- "Placement" text NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "FencingPoly_Geom_idx" ON "work"."FencingPoly" USING gist ("Geometry");

ALTER TABLE "work"."FencingPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."FencingPoly" TO mggt;
GRANT ALL ON TABLE "work"."FencingPoly" TO postgres;
GRANT ALL ON TABLE "work"."FencingPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."FencingPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."FencingPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."FencingPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."FencingPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."FencingPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."FencingPoly" IS 'Ограждения (Точка)';
COMMENT ON COLUMN "work"."FencingPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."FencingPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."FencingPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."FencingPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."FencingPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."FencingPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."FencingPoly"."EquipmentKind" IS 'Код типа ограждения';
COMMENT ON COLUMN "work"."FencingPoly"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."FencingPoly"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."FencingPoly"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."FencingPoly"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."FencingPoly"."QuantityRm" IS 'Протяженность, п.м';
COMMENT ON COLUMN "work"."FencingPoly"."QuantityPcs" IS 'Количество, шт.';
COMMENT ON COLUMN "work"."FencingPoly"."Area" IS 'Площадь, кв.м';
COMMENT ON COLUMN "work"."FencingPoly"."GuttersLength" IS 'Двухметровая прилотковая зона, п.м.';
-- Удалено в новой версии
-- COMMENT ON COLUMN "work"."FencingPoly"."Placement" IS 'Код места размещения';
COMMENT ON COLUMN "work"."FencingPoly"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."FencingPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."FencingPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."FencingPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."FencingPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."FencingPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."FencingPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."FencingPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."FencingPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."FencingPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."FencingPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."FencingPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."FencingPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Цветники
CREATE TABLE IF NOT EXISTS "work"."FlowersGardenPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "SectionNum" int8 NULL,
    "GreenNum" int8 NULL,
    "TotalArea" float8 NULL,
    "AnnualsArea" float8 NULL,
    "PerennialsArea" float8 NULL,
    "InertArea" float8 NULL,
    "ShrubsArea" float8 NULL,
    "WithShrubsArea" float8 NULL,
    "SeasonShiftArea" float8 NULL,
    "BulbousArea" float8 NULL,
    "TulipArea" float8 NULL,
    "BiennialsArea" float8 NULL,
    "FlindersArea" float8 NULL,
    "InertStoneChipsArea" float8 NULL,
    "InertTreeBarkArea" float8 NULL,
    "InertOtherArea" float8 NULL,
    "RockeryArea" float8 NULL,
    "LawnArea" float8 NULL,
    -- Убрано в новой версии
    -- "VaseQty" int8 NULL,
    -- "FloorVerticalDesignQty" int8 NULL,
    -- "SuspendVerticalDesignQty" int8 NULL,
    -- "FlowersVerticalDesignQty" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "FlowersGardenPoly_Geom_idx" ON "work"."FlowersGardenPoly" USING gist ("Geometry");

ALTER TABLE "work"."FlowersGardenPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."FlowersGardenPoly" TO mggt;
GRANT ALL ON TABLE "work"."FlowersGardenPoly" TO postgres;
GRANT ALL ON TABLE "work"."FlowersGardenPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."FlowersGardenPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."FlowersGardenPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."FlowersGardenPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."FlowersGardenPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."FlowersGardenPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."FlowersGardenPoly" IS 'Цветники';
COMMENT ON COLUMN "work"."FlowersGardenPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."SectionNum" IS '№ участка';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."GreenNum" IS 'Номер цветника';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."TotalArea" IS 'Общая площадь цветника, кв.м.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."AnnualsArea" IS 'Однолетники, кв.м.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."PerennialsArea" IS 'Многолетники и розы, кв.м.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."InertArea" IS 'Инертный материал (отсыпка), кв.м.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."ShrubsArea" IS 'Декоративные кустарники, кв.м.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."WithShrubsArea" IS 'С учетом кустарников, кв.м.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."SeasonShiftArea" IS 'С учетом сезонной сменности, кв.м.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."BulbousArea" IS 'Луковичные и клубнелуковичные кроме тюльпанов, нарциссов, кв.м.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."TulipArea" IS 'Тюльпаны, нарциссы, кв.м.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."BiennialsArea" IS 'Двулетники (виола), кв.м.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."FlindersArea" IS 'Декорирование щепой, кв.м.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."InertStoneChipsArea" IS 'Инертный материал (отсыпка), каменная крошка, кв.м';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."InertTreeBarkArea" IS 'Инертный материал (отсыпка), древесная кора (щепа), кв.м';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."InertOtherArea" IS 'Инертный материал (отсыпка), иное, кв.м';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."RockeryArea" IS 'Рокарий (многолетние, однолетние), кв.м.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."LawnArea" IS 'Газон (как элемент цветника), кв.м.';
-- Убрано в новой версии
-- COMMENT ON COLUMN "work"."FlowersGardenPoly"."VaseQty" IS 'Вазоны шт.';
-- COMMENT ON COLUMN "work"."FlowersGardenPoly"."FloorVerticalDesignQty" IS 'Напольные вертикальные конструкции шт.';
-- COMMENT ON COLUMN "work"."FlowersGardenPoly"."SuspendVerticalDesignQty" IS 'Подвесные вертикальные конструкции шт.';
-- COMMENT ON COLUMN "work"."FlowersGardenPoly"."FlowersVerticalDesignQty" IS 'Цветочные вертикальные конструкции шт.';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."FlowersGardenPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Системы функционального обеспечения (Линия)
CREATE TABLE IF NOT EXISTS "work"."FunctionalityLine"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ArrangeElementType" text NULL,
    "Quantity" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "CoatingFaceType" text NULL,
    "FaceArea" float8 NULL,
    "ZoneOghObjectType" text NULL,
    "ZoneOghObjectRootId" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "FunctionalityLine_Geom_idx" ON "work"."FunctionalityLine" USING gist ("Geometry");

ALTER TABLE "work"."FunctionalityLine" OWNER to postgres;
GRANT ALL ON TABLE "work"."FunctionalityLine" TO mggt;
GRANT ALL ON TABLE "work"."FunctionalityLine" TO postgres;
GRANT ALL ON TABLE "work"."FunctionalityLine" TO mggt_editor;
GRANT SELECT ON TABLE "work"."FunctionalityLine" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."FunctionalityLine_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."FunctionalityLine_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."FunctionalityLine_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."FunctionalityLine_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."FunctionalityLine" IS 'Системы функционального обеспечения (Линия)';
COMMENT ON COLUMN "work"."FunctionalityLine".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."FunctionalityLine"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."FunctionalityLine"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."FunctionalityLine"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."FunctionalityLine"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."FunctionalityLine"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."FunctionalityLine"."ArrangeElementType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."FunctionalityLine"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."FunctionalityLine"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."FunctionalityLine"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."FunctionalityLine"."CoatingFaceType" IS 'Код вида покрытия (облицовка)';
COMMENT ON COLUMN "work"."FunctionalityLine"."FaceArea" IS 'Площадь облицовки, кв.м.';
COMMENT ON COLUMN "work"."FunctionalityLine"."ZoneOghObjectType" IS 'Код типа объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."FunctionalityLine"."ZoneOghObjectRootId" IS 'Идентификатор объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."FunctionalityLine"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."FunctionalityLine"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."FunctionalityLine"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."FunctionalityLine"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityLine"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityLine"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityLine"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityLine"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityLine"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."FunctionalityLine"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."FunctionalityLine"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."FunctionalityLine"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."FunctionalityLine"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."FunctionalityLine"."Geometry" IS 'Геометрия объекта';


-- Создаём Системы функционального обеспечения (Точка)
CREATE TABLE IF NOT EXISTS "work"."FunctionalityPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ArrangeElementType" text NULL,
    "Quantity" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "CoatingFaceType" text NULL,
    "FaceArea" float8 NULL,
    "ZoneOghObjectType" text NULL,
    "ZoneOghObjectRootId" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "FunctionalityPoint_Geom_idx" ON "work"."FunctionalityPoint" USING gist ("Geometry");

ALTER TABLE "work"."FunctionalityPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."FunctionalityPoint" TO mggt;
GRANT ALL ON TABLE "work"."FunctionalityPoint" TO postgres;
GRANT ALL ON TABLE "work"."FunctionalityPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."FunctionalityPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."FunctionalityPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."FunctionalityPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."FunctionalityPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."FunctionalityPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."FunctionalityPoint" IS 'Системы функционального обеспечения (Точка)';
COMMENT ON COLUMN "work"."FunctionalityPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."FunctionalityPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."FunctionalityPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."FunctionalityPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."FunctionalityPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."FunctionalityPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."FunctionalityPoint"."ArrangeElementType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."FunctionalityPoint"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."FunctionalityPoint"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."FunctionalityPoint"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."FunctionalityPoint"."CoatingFaceType" IS 'Код вида покрытия (облицовка)';
COMMENT ON COLUMN "work"."FunctionalityPoint"."FaceArea" IS 'Площадь облицовки, кв.м.';
COMMENT ON COLUMN "work"."FunctionalityPoint"."ZoneOghObjectType" IS 'Код типа объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."FunctionalityPoint"."ZoneOghObjectRootId" IS 'Идентификатор объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."FunctionalityPoint"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."FunctionalityPoint"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."FunctionalityPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."FunctionalityPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."FunctionalityPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."FunctionalityPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."FunctionalityPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."FunctionalityPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."FunctionalityPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Системы функционального обеспечения (Полигон)
CREATE TABLE IF NOT EXISTS "work"."FunctionalityPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ArrangeElementType" text NULL,
    "Quantity" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "CoatingFaceType" text NULL,
    "FaceArea" float8 NULL,
    "ZoneOghObjectType" text NULL,
    "ZoneOghObjectRootId" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "FunctionalityPoly_Geom_idx" ON "work"."FunctionalityPoly" USING gist ("Geometry");

ALTER TABLE "work"."FunctionalityPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."FunctionalityPoly" TO mggt;
GRANT ALL ON TABLE "work"."FunctionalityPoly" TO postgres;
GRANT ALL ON TABLE "work"."FunctionalityPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."FunctionalityPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."FunctionalityPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."FunctionalityPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."FunctionalityPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."FunctionalityPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."FunctionalityPoly" IS 'Системы функционального обеспечения (Полигон)';
COMMENT ON COLUMN "work"."FunctionalityPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."FunctionalityPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."FunctionalityPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."FunctionalityPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."FunctionalityPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."FunctionalityPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."FunctionalityPoly"."ArrangeElementType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."FunctionalityPoly"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."FunctionalityPoly"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."FunctionalityPoly"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."FunctionalityPoly"."CoatingFaceType" IS 'Код вида покрытия (облицовка)';
COMMENT ON COLUMN "work"."FunctionalityPoly"."FaceArea" IS 'Площадь облицовки, кв.м.';
COMMENT ON COLUMN "work"."FunctionalityPoly"."ZoneOghObjectType" IS 'Код типа объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."FunctionalityPoly"."ZoneOghObjectRootId" IS 'Идентификатор объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."FunctionalityPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."FunctionalityPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."FunctionalityPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."FunctionalityPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."FunctionalityPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."FunctionalityPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."FunctionalityPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."FunctionalityPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."FunctionalityPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."FunctionalityPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Иной объект благоустройства
CREATE TABLE IF NOT EXISTS "work"."ImprovementObjectPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "Name" text NULL,
    "OwnerLegalPersonId" int8 NULL,
    "OwnerLegalPersonVersionId" int8 NULL,
    "OwnerStartDate" timestamp NULL,
    "OwnerEndDate" timestamp NULL,
    "DepartmentLegalPersonId" int8 NULL,
    "DepartmentLegalPersonVersionId" int8 NULL,
    "DepartmentStartDate" timestamp NULL,
    "DepartmentEndDate" timestamp NULL,
    "CustomerLegalPersonId" int8 NULL,
    "CustomerLegalPersonVersionId" int8 NULL,
    "CustomerStartDate" timestamp NULL,
    "CustomertEndDate" timestamp NULL,
    "ImprovementCategory" text NULL,
    "ImprovementObjectCategory" text NULL,
    "Unom" int8 NULL,
    "Unad" int8 NULL,
    "TotalArea" float8 NULL,
    "TotalCleanArea" float8 NULL,
    "ManualCleanArea" float8 NULL,
    "AutoCleanArea" float8 NULL,
    "TotalCoverCleanArea" float8 NULL,
    "AsphaltCleanArea" float8 NULL,
    "SlabCleanArea" float8 NULL,
    "SoilCleanArea" float8 NULL,
    "RubberCleanArea" float8 NULL,
    "SandCleanArea" float8 NULL,
    "GraniteCleanArea" float8 NULL,
    "GrassCleanArea" float8 NULL,
    "PlasticCleanArea" float8 NULL,
    "GrassPaverCleanArea" float8 NULL,
    "TotalLawnArea" float8 NULL,
    "UsialLawnArea" float8 NULL,
    "ParterreLawnArea" float8 NULL,
    "LawnGridArea" float8 NULL,
    "LawnLawnArea" float8 NULL,
    "SlopeLawnArea" float8 NULL,
    "LawnOtherArea" float8 NULL,
    "CoverImproveAutoCleanArea" float8 NULL,
    "SnowCleanArea" float8 NULL,
    "OtherImprovementObjectType" text NULL,
    "ReservoirArea" float8 NULL,
    "RepairsInfoList" text NULL,
    "RepairsInfoListPlan" text NULL,
    "FileList" text NULL,
    "Tree" text NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "ImprovementObjectPoly_Geom_idx" ON "work"."ImprovementObjectPoly" USING gist ("Geometry");

ALTER TABLE "work"."ImprovementObjectPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."ImprovementObjectPoly" TO mggt;
GRANT ALL ON TABLE "work"."ImprovementObjectPoly" TO postgres;
GRANT ALL ON TABLE "work"."ImprovementObjectPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."ImprovementObjectPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."ImprovementObjectPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."ImprovementObjectPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."ImprovementObjectPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."ImprovementObjectPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."ImprovementObjectPoly" IS 'Иной объект благоустройства';
COMMENT ON COLUMN "work"."ImprovementObjectPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."Name" IS 'Наименование объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."OwnerLegalPersonId" IS 'ID балансодержателя';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."OwnerLegalPersonVersionId" IS 'Версия балансодержателя';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."OwnerStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."OwnerEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."DepartmentLegalPersonId" IS 'ID ведомственного ОИВ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."DepartmentLegalPersonVersionId" IS 'Версия ведомственного ОИВ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."DepartmentStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."DepartmentEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CustomerLegalPersonId" IS 'ID заказчика';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CustomerLegalPersonVersionId" IS 'Версия заказчика';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CustomerStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CustomertEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ImprovementCategory" IS 'Категория благоустройства';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ImprovementObjectCategory" IS 'Категория озеленения';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."Unom" IS 'Данные UNOM';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."Unad" IS 'Данные UNAD';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TotalArea" IS 'Общая площадь объекта, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TotalCleanArea" IS 'Общая уборочная площадь, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ManualCleanArea" IS 'Площадь ручной уборки, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."AutoCleanArea" IS 'Площадь механизированной уборки, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TotalCoverCleanArea" IS 'Общая уборочная площадь по покрытиям, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."AsphaltCleanArea" IS 'Асфальтобетонное, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."SlabCleanArea" IS 'Плиточное (Плитка или тактильная плитка), кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."SoilCleanArea" IS 'Грунтовое, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."RubberCleanArea" IS 'Мягкое из резиновой крошки, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."SandCleanArea" IS 'Мягкое из песка, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."GraniteCleanArea" IS 'Мягкое из гранитной высевки, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."GrassCleanArea" IS 'Мягкое из искусственной травы, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."PlasticCleanArea" IS 'Пластиковое, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."GrassPaverCleanArea" IS 'Газонная решетка (экопарковка), кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TotalLawnArea" IS 'Общая площадь газонов, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."UsialLawnArea" IS 'Обыкновенный, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ParterreLawnArea" IS 'Партерный, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."LawnGridArea" IS 'На ячеистом основании, экопарковки, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."LawnLawnArea" IS 'Луговой, разнотравный, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."SlopeLawnArea" IS 'На откосе, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."LawnOtherArea" IS 'Иного типа, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CoverImproveAutoCleanArea" IS 'Территория уборки усовершенствованных покрытий, механизированная';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."SnowCleanArea" IS 'Площадь вывоза снега, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."OtherImprovementObjectType" IS 'Код типа ИОБ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ReservoirArea" IS 'Водоемы, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."RepairsInfoList" IS 'Перечень ремонтных работ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."RepairsInfoListPlan" IS 'Перечень проектных работ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."Tree" IS 'Перечень дочерних объектов';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."IsDiffHeightMark" IS 'Признак «Разновысотный ОГХ»';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Опоры освещения и контактных сетей
CREATE TABLE IF NOT EXISTS "work"."LamppostsPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ConvElementType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "Endwise" float8 NULL,
    "Material" text NULL,
    "Placement" text NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "LamppostsPoint_Geom_idx" ON "work"."LamppostsPoint" USING gist ("Geometry");

ALTER TABLE "work"."LamppostsPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."LamppostsPoint" TO mggt;
GRANT ALL ON TABLE "work"."LamppostsPoint" TO postgres;
GRANT ALL ON TABLE "work"."LamppostsPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."LamppostsPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."LamppostsPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."LamppostsPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."LamppostsPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."LamppostsPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."LamppostsPoint" IS 'Опоры освещения и контактных сетей';
COMMENT ON COLUMN "work"."LamppostsPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."LamppostsPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."LamppostsPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."LamppostsPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."LamppostsPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."LamppostsPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."LamppostsPoint"."ConvElementType" IS 'Код типа опоры';
COMMENT ON COLUMN "work"."LamppostsPoint"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."LamppostsPoint"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."LamppostsPoint"."Endwise" IS 'По оси, м';
COMMENT ON COLUMN "work"."LamppostsPoint"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."LamppostsPoint"."Placement" IS 'Код места размещения';
COMMENT ON COLUMN "work"."LamppostsPoint"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."LamppostsPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."LamppostsPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."LamppostsPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."LamppostsPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."LamppostsPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."LamppostsPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."LamppostsPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."LamppostsPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."LamppostsPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."LamppostsPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."LamppostsPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."LamppostsPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Газоны
CREATE TABLE IF NOT EXISTS "work"."LawnPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "SectionNum" int8 NULL,
    "TotalLawnArea" float8 NULL,
    "LawnType" text NULL,
    "StateGardening" text NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsSmmCleaning" bool NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "LawnPoly_Geom_idx" ON "work"."LawnPoly" USING gist ("Geometry");

ALTER TABLE "work"."LawnPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."LawnPoly" TO mggt;
GRANT ALL ON TABLE "work"."LawnPoly" TO postgres;
GRANT ALL ON TABLE "work"."LawnPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."LawnPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."LawnPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."LawnPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."LawnPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."LawnPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."LawnPoly" IS 'Газоны';
COMMENT ON COLUMN "work"."LawnPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."LawnPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."LawnPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."LawnPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."LawnPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."LawnPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."LawnPoly"."SectionNum" IS '№ участка';
COMMENT ON COLUMN "work"."LawnPoly"."TotalLawnArea" IS 'Площадь кв.м';
COMMENT ON COLUMN "work"."LawnPoly"."LawnType" IS 'Код типа газона';
COMMENT ON COLUMN "work"."LawnPoly"."StateGardening" IS 'Код состояния';
COMMENT ON COLUMN "work"."LawnPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."LawnPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."LawnPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."LawnPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."LawnPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."LawnPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."LawnPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."LawnPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."LawnPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."LawnPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."LawnPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."LawnPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."LawnPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."LawnPoly"."IsSmmCleaning" IS 'Признак «Уборка с применением СММ»';
COMMENT ON COLUMN "work"."LawnPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Малые архитектурные формы и элементы благоустройства (Линия)
CREATE TABLE IF NOT EXISTS "work"."LittleFormLine"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "MafTypeLevel1" text NULL,
    "MafTypeLevel2" text NULL,
    "MafTypeLevel3" text NULL,
    "MafQuantityCharacteristics" float8 NULL,
    "Quantity" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "InstallationDate" timestamp NULL,
    "Lifetime" timestamp NULL,
    "GuaranteePeriod" timestamp NULL,
    "IdRfid" text NULL,
    "ZoneOghObjectType" text NULL,
    "ZoneOghObjectRootId" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "LittleFormLine_Geom_idx" ON "work"."LittleFormLine" USING gist ("Geometry");

ALTER TABLE "work"."LittleFormLine" OWNER to postgres;
GRANT ALL ON TABLE "work"."LittleFormLine" TO mggt;
GRANT ALL ON TABLE "work"."LittleFormLine" TO postgres;
GRANT ALL ON TABLE "work"."LittleFormLine" TO mggt_editor;
GRANT SELECT ON TABLE "work"."LittleFormLine" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."LittleFormLine_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."LittleFormLine_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."LittleFormLine_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."LittleFormLine_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."LittleFormLine" IS 'Малые архитектурные формы и элементы благоустройства (Линия)';
COMMENT ON COLUMN "work"."LittleFormLine".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."LittleFormLine"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."LittleFormLine"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."LittleFormLine"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."LittleFormLine"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."LittleFormLine"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."LittleFormLine"."MafTypeLevel1" IS 'Код типа МАФ.Уровень 1';
COMMENT ON COLUMN "work"."LittleFormLine"."MafTypeLevel2" IS 'Код типа МАФ.Уровень 2';
COMMENT ON COLUMN "work"."LittleFormLine"."MafTypeLevel3" IS 'Код типа МАФ.Уровень 3';
COMMENT ON COLUMN "work"."LittleFormLine"."MafQuantityCharacteristics" IS 'Количественная характеристика МАФ (если такая есть у выбранного типа МАФ)';
COMMENT ON COLUMN "work"."LittleFormLine"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."LittleFormLine"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."LittleFormLine"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."LittleFormLine"."InstallationDate" IS 'Дата установки';
COMMENT ON COLUMN "work"."LittleFormLine"."Lifetime" IS 'Срок эксплуатации';
COMMENT ON COLUMN "work"."LittleFormLine"."GuaranteePeriod" IS 'Гарантийный срок';
COMMENT ON COLUMN "work"."LittleFormLine"."IdRfid" IS 'ID RFID метки';
COMMENT ON COLUMN "work"."LittleFormLine"."ZoneOghObjectType" IS 'Код типа объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."LittleFormLine"."ZoneOghObjectRootId" IS 'Идентификатор объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."LittleFormLine"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."LittleFormLine"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."LittleFormLine"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."LittleFormLine"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."LittleFormLine"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."LittleFormLine"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."LittleFormLine"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."LittleFormLine"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."LittleFormLine"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."LittleFormLine"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."LittleFormLine"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."LittleFormLine"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."LittleFormLine"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."LittleFormLine"."Geometry" IS 'Геометрия объекта';


-- Создаём Малые архитектурные формы и элементы благоустройства (Точка)
CREATE TABLE IF NOT EXISTS "work"."LittleFormPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "MafTypeLevel1" text NULL,
    "MafTypeLevel2" text NULL,
    "MafTypeLevel3" text NULL,
    "MafQuantityCharacteristics" float8 NULL,
    "Quantity" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "InstallationDate" timestamp NULL,
    "Lifetime" timestamp NULL,
    "GuaranteePeriod" timestamp NULL,
    "IdRfid" text NULL,
    "ZoneOghObjectType" text NULL,
    "ZoneOghObjectRootId" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "LittleFormPoint_Geom_idx" ON "work"."LittleFormPoint" USING gist ("Geometry");

ALTER TABLE "work"."LittleFormPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."LittleFormPoint" TO mggt;
GRANT ALL ON TABLE "work"."LittleFormPoint" TO postgres;
GRANT ALL ON TABLE "work"."LittleFormPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."LittleFormPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."LittleFormPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."LittleFormPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."LittleFormPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."LittleFormPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."LittleFormPoint" IS 'Малые архитектурные формы и элементы благоустройства (Точка)';
COMMENT ON COLUMN "work"."LittleFormPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."LittleFormPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."LittleFormPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."LittleFormPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."LittleFormPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."LittleFormPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."LittleFormPoint"."MafTypeLevel1" IS 'Код типа МАФ.Уровень 1';
COMMENT ON COLUMN "work"."LittleFormPoint"."MafTypeLevel2" IS 'Код типа МАФ.Уровень 2';
COMMENT ON COLUMN "work"."LittleFormPoint"."MafTypeLevel3" IS 'Код типа МАФ.Уровень 3';
COMMENT ON COLUMN "work"."LittleFormPoint"."MafQuantityCharacteristics" IS 'Количественная характеристика МАФ (если такая есть у выбранного типа МАФ)';
COMMENT ON COLUMN "work"."LittleFormPoint"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."LittleFormPoint"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."LittleFormPoint"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."LittleFormPoint"."InstallationDate" IS 'Дата установки';
COMMENT ON COLUMN "work"."LittleFormPoint"."Lifetime" IS 'Срок эксплуатации';
COMMENT ON COLUMN "work"."LittleFormPoint"."GuaranteePeriod" IS 'Гарантийный срок';
COMMENT ON COLUMN "work"."LittleFormPoint"."IdRfid" IS 'ID RFID метки';
COMMENT ON COLUMN "work"."LittleFormPoint"."ZoneOghObjectType" IS 'Код типа объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."LittleFormPoint"."ZoneOghObjectRootId" IS 'Идентификатор объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."LittleFormPoint"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."LittleFormPoint"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."LittleFormPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."LittleFormPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."LittleFormPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."LittleFormPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."LittleFormPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."LittleFormPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."LittleFormPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."LittleFormPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."LittleFormPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."LittleFormPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."LittleFormPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."LittleFormPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Малые архитектурные формы и элементы благоустройства (Полигон)
CREATE TABLE IF NOT EXISTS "work"."LittleFormPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "MafTypeLevel1" text NULL,
    "MafTypeLevel2" text NULL,
    "MafTypeLevel3" text NULL,
    "MafQuantityCharacteristics" float8 NULL,
    "Quantity" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "InstallationDate" timestamp NULL,
    "Lifetime" timestamp NULL,
    "GuaranteePeriod" timestamp NULL,
    "IdRfid" text NULL,
    "ZoneOghObjectType" text NULL,
    "ZoneOghObjectRootId" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "LittleFormPoly_Geom_idx" ON "work"."LittleFormPoly" USING gist ("Geometry");

ALTER TABLE "work"."LittleFormPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."LittleFormPoly" TO mggt;
GRANT ALL ON TABLE "work"."LittleFormPoly" TO postgres;
GRANT ALL ON TABLE "work"."LittleFormPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."LittleFormPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."LittleFormPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."LittleFormPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."LittleFormPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."LittleFormPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."LittleFormPoly" IS 'Малые архитектурные формы и элементы благоустройства (Полигон)';
COMMENT ON COLUMN "work"."LittleFormPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."LittleFormPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."LittleFormPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."LittleFormPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."LittleFormPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."LittleFormPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."LittleFormPoly"."MafTypeLevel1" IS 'Код типа МАФ.Уровень 1';
COMMENT ON COLUMN "work"."LittleFormPoly"."MafTypeLevel2" IS 'Код типа МАФ.Уровень 2';
COMMENT ON COLUMN "work"."LittleFormPoly"."MafTypeLevel3" IS 'Код типа МАФ.Уровень 3';
COMMENT ON COLUMN "work"."LittleFormPoly"."MafQuantityCharacteristics" IS 'Количественная характеристика МАФ (если такая есть у выбранного типа МАФ)';
COMMENT ON COLUMN "work"."LittleFormPoly"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."LittleFormPoly"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."LittleFormPoly"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."LittleFormPoly"."InstallationDate" IS 'Дата установки';
COMMENT ON COLUMN "work"."LittleFormPoly"."Lifetime" IS 'Срок эксплуатации';
COMMENT ON COLUMN "work"."LittleFormPoly"."GuaranteePeriod" IS 'Гарантийный срок';
COMMENT ON COLUMN "work"."LittleFormPoly"."IdRfid" IS 'ID RFID метки';
COMMENT ON COLUMN "work"."LittleFormPoly"."ZoneOghObjectType" IS 'Код типа объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."LittleFormPoly"."ZoneOghObjectRootId" IS 'Идентификатор объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."LittleFormPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."LittleFormPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."LittleFormPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."LittleFormPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."LittleFormPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."LittleFormPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."LittleFormPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."LittleFormPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."LittleFormPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."LittleFormPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."LittleFormPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."LittleFormPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."LittleFormPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."LittleFormPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Малые архитектурные формы (Точка)
CREATE TABLE IF NOT EXISTS "work"."MafPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ConvElementType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "Property" text NULL,
    "Area" float8 NULL,
    "IsObjectArea" bool NULL,
    "Placement" text NULL,
    "IdRfid" text NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "MafPoint_Geom_idx" ON "work"."MafPoint" USING gist ("Geometry");

ALTER TABLE "work"."MafPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."MafPoint" TO mggt;
GRANT ALL ON TABLE "work"."MafPoint" TO postgres;
GRANT ALL ON TABLE "work"."MafPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."MafPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."MafPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."MafPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."MafPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."MafPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."MafPoint" IS 'Малые архитектурные формы (Точка)';
COMMENT ON COLUMN "work"."MafPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."MafPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."MafPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."MafPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."MafPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."MafPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."MafPoint"."ConvElementType" IS 'Код типа МАФ';
COMMENT ON COLUMN "work"."MafPoint"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."MafPoint"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."MafPoint"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."MafPoint"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."MafPoint"."Property" IS 'Краткая характеристика';
COMMENT ON COLUMN "work"."MafPoint"."Area" IS 'Площадь, кв.м';
COMMENT ON COLUMN "work"."MafPoint"."IsObjectArea" IS 'Входит в общую площадь ОДХ';
COMMENT ON COLUMN "work"."MafPoint"."Placement" IS 'Код места размещения';
COMMENT ON COLUMN "work"."MafPoint"."IdRfid" IS 'ID RFID метки';
COMMENT ON COLUMN "work"."MafPoint"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."MafPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."MafPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."MafPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."MafPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."MafPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."MafPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."MafPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."MafPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."MafPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."MafPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."MafPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."MafPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Малые архитектурные формы (Полигон)
CREATE TABLE IF NOT EXISTS "work"."MafPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ConvElementType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "Property" text NULL,
    "Area" float8 NULL,
    "IsObjectArea" bool NULL,
    "Placement" text NULL,
    "IdRfid" text NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL,
    "AxisGeometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "MafPoly_Geom_idx" ON "work"."MafPoly" USING gist ("Geometry");
CREATE INDEX IF NOT EXISTS "MafPoly_AxisGeom_idx" ON "work"."MafPoly" USING gist ("AxisGeometry");

ALTER TABLE "work"."MafPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."MafPoly" TO mggt;
GRANT ALL ON TABLE "work"."MafPoly" TO postgres;
GRANT ALL ON TABLE "work"."MafPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."MafPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."MafPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."MafPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."MafPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."MafPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."MafPoly" IS 'Малые архитектурные формы (Полигон)';
COMMENT ON COLUMN "work"."MafPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."MafPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."MafPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."MafPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."MafPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."MafPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."MafPoly"."ConvElementType" IS 'Код типа МАФ';
COMMENT ON COLUMN "work"."MafPoly"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."MafPoly"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."MafPoly"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."MafPoly"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."MafPoly"."Property" IS 'Краткая характеристика';
COMMENT ON COLUMN "work"."MafPoly"."Area" IS 'Площадь, кв.м';
COMMENT ON COLUMN "work"."MafPoly"."IsObjectArea" IS 'Входит в общую площадь ОДХ';
COMMENT ON COLUMN "work"."MafPoly"."Placement" IS 'Код места размещения';
COMMENT ON COLUMN "work"."MafPoly"."IdRfid" IS 'ID RFID метки';
COMMENT ON COLUMN "work"."MafPoly"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."MafPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."MafPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."MafPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."MafPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."MafPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."MafPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."MafPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."MafPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."MafPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."MafPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."MafPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."MafPoly"."Geometry" IS 'Геометрия объекта';
COMMENT ON COLUMN "work"."MafPoly"."AxisGeometry" IS 'Геометрия осевой линии объекта';


-- Создаём Люки смотровых колодцев и решетки водоприемных колодцев
CREATE TABLE IF NOT EXISTS "work"."ManholesPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "EngineStructType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "Endwise" float8 NULL,
    "Placement" text NULL,
    "Accessory" text NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "ManholesPoint_Geom_idx" ON "work"."ManholesPoint" USING gist ("Geometry");

ALTER TABLE "work"."ManholesPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."ManholesPoint" TO mggt;
GRANT ALL ON TABLE "work"."ManholesPoint" TO postgres;
GRANT ALL ON TABLE "work"."ManholesPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."ManholesPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."ManholesPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."ManholesPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."ManholesPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."ManholesPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."ManholesPoint" IS 'Люки смотровых колодцев и решетки водоприемных колодцев';
COMMENT ON COLUMN "work"."ManholesPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."ManholesPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."ManholesPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."ManholesPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."ManholesPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."ManholesPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."ManholesPoint"."EngineStructType" IS 'Код типа люка и решетки';
COMMENT ON COLUMN "work"."ManholesPoint"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."ManholesPoint"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."ManholesPoint"."Endwise" IS 'По оси, м';
COMMENT ON COLUMN "work"."ManholesPoint"."Placement" IS 'Код местоположения';
COMMENT ON COLUMN "work"."ManholesPoint"."Accessory" IS 'Код принадлежности';
COMMENT ON COLUMN "work"."ManholesPoint"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."ManholesPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."ManholesPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."ManholesPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."ManholesPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."ManholesPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."ManholesPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."ManholesPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."ManholesPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."ManholesPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."ManholesPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."ManholesPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."ManholesPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Обочины
CREATE TABLE IF NOT EXISTS "work"."MarginPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "FlatElementType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "MarginStrengType" text NULL,
    "CoatingGroup" text NULL,
    "Area" float8 NULL,
    "Distance" float8 NULL,
    "WidthBegin" float8 NULL,
    "WidthEnd" float8 NULL,
    "AutoCleanArea" float8 NULL,
    "ManualCleanArea" float8 NULL,
    "NoCleanArea" float8 NULL,
    "Description" text NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL,
    "AxisGeometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "MarginPoly_Geom_idx" ON "work"."MarginPoly" USING gist ("Geometry");
CREATE INDEX IF NOT EXISTS "MarginPoly_AxisGeom_idx" ON "work"."MarginPoly" USING gist ("AxisGeometry");

ALTER TABLE "work"."MarginPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."MarginPoly" TO mggt;
GRANT ALL ON TABLE "work"."MarginPoly" TO postgres;
GRANT ALL ON TABLE "work"."MarginPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."MarginPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."MarginPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."MarginPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."MarginPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."MarginPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."MarginPoly" IS 'Обочины';
COMMENT ON COLUMN "work"."MarginPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."MarginPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."MarginPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."MarginPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."MarginPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."MarginPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."MarginPoly"."FlatElementType" IS 'Код типа обочины';
COMMENT ON COLUMN "work"."MarginPoly"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."MarginPoly"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."MarginPoly"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."MarginPoly"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."MarginPoly"."MarginStrengType" IS 'Код наименования типа укрепления';
COMMENT ON COLUMN "work"."MarginPoly"."CoatingGroup" IS 'Код группы укрепления';
COMMENT ON COLUMN "work"."MarginPoly"."Area" IS 'Площадь, кв. м.';
COMMENT ON COLUMN "work"."MarginPoly"."Distance" IS 'Длина, п.м';
COMMENT ON COLUMN "work"."MarginPoly"."WidthBegin" IS 'Ширина в начале, м';
COMMENT ON COLUMN "work"."MarginPoly"."WidthEnd" IS 'Ширина в конце, м';
COMMENT ON COLUMN "work"."MarginPoly"."AutoCleanArea" IS 'Площадь уборки мех., кв.м';
COMMENT ON COLUMN "work"."MarginPoly"."ManualCleanArea" IS 'Площадь уборки ручн., кв.м';
COMMENT ON COLUMN "work"."MarginPoly"."NoCleanArea" IS 'Площадь без уборки, кв.м';
COMMENT ON COLUMN "work"."MarginPoly"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."MarginPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."MarginPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."MarginPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."MarginPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."MarginPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."MarginPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."MarginPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."MarginPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."MarginPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."MarginPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."MarginPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."MarginPoly"."Geometry" IS 'Геометрия объекта';
COMMENT ON COLUMN "work"."MarginPoly"."AxisGeometry" IS 'Геометрия осевой линии объекта';


-- Создаём Объект дорожного хозяйства
CREATE TABLE IF NOT EXISTS "work"."OdhPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "Name" text NULL,
    "OwnerLegalPersonId" int8 NULL,
    "OwnerLegalPersonVersionId" int8 NULL,
    "OwnerStartDate" timestamp NULL,
    "OwnerEndDate" timestamp NULL,
    "GrbsLegalPersonId" int8 NULL,
    "GrbsLegalPersonVersionId" int8 NULL,
    "GrbsStartDate" timestamp NULL,
    "GrbsEndDate" timestamp NULL,
    "CustomerLegalPersonId" int8 NULL,
    "CustomerLegalPersonVersionId" int8 NULL,
    "CustomerStartDate" timestamp NULL,
    "CustomertEndDate" timestamp NULL,
    "CleanCategory" text NULL,
    "CleanSubcategory" text NULL,
    "Intensity" float8 NULL,
    "CategorySp" text NULL,
    "PassportDraftOrg" text NULL,
    "PassportDate" timestamp NULL,
    "Description" text NULL,
    "Distance" float8 NULL,
    "LayoutLength" float8 NULL,
    "AxisLength" float8 NULL,
    "SnowArea" float8 NULL,
    "RotorArea" float8 NULL,
    "ReagentArea" float8 NULL,
    "ActualSchemaDate" timestamp NULL,
    "IsDiffHeightMark" bool NULL,
    "InboundArea" float8 NULL,
    "TotalArea" float8 NULL,
    "TpuArea" float8 NULL,
    "GuttersLength" float8 NULL,
    "RoadwayArea" float8 NULL,
    "MarginArea" float8 NULL,
    "FootwayArea" float8 NULL,
    "BoundStoneLength" float8 NULL,
    "TramRailsLength" float8 NULL,
    "TrafficSignsQty" int8 NULL,
    "TraffLightQty" int8 NULL,
    "StationQty" int8 NULL,
    "GuidingArea" float8 NULL,
    "GuidingLength" float8 NULL,
    "GuidingQty" float8 NULL,
    "OtherArea" float8 NULL,
    "EnginQty" int8 NULL,
    "BicycleArea" float8 NULL,
    "BicycleLength" float8 NULL,
    "CleaningArea" float8 NULL,
    "RoadwayNoprkgManualCleanArea" float8 NULL,
    "RoadwayNoprkgAutoCleanArea" float8 NULL,
    "RoadwayPrkgManualCleanArea" float8 NULL,
    "RoadwayPrkgAutoCleanArea" float8 NULL,
    "AutoFootwayArea" float8 NULL,
    "ManualFootwayArea" float8 NULL,
    "StationNumber" int8 NULL,
    "StationArea" float8 NULL,
    "BarNewJersey" float8 NULL,
    "Buffer" float8 NULL,
    "Asperity" int8 NULL,
    "Sign" int8 NULL,
    "Info" int8 NULL,
    "CleaningGuidingLength" float8 NULL,
    "CleaningGuidingArea" float8 NULL,
    "CleaningGuidingQty" float8 NULL,
    "BarAntinoise" float8 NULL,
    "Pointer" int8 NULL,
    "NavigationPointer" float8 NULL,
    "BarWave" float8 NULL,
    "BarTrans" float8 NULL,
    "BarPipe" float8 NULL,
    "FootwayPole" float8 NULL,
    "BarFracasso" float8 NULL,
    "BarConcrete" float8 NULL,
    "BarFoot" float8 NULL,
    "MarginAutoCleanArea" float8 NULL,
    "MarginManualCleanArea" float8 NULL,
    "RepairsInfoList" text NULL,
    "RepairsInfoListPlan" text NULL,
    "FileList" text NULL,
    "Tree" text NULL,
    "TrafficCharacterList" text NULL,
    "CreateType" text NULL,
    "PassDevInitiator" text NULL,
    "DateSurvey" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"PassBrId" int8 NULL,
	"Landscaping" text NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "OdhPoly_Geom_idx" ON "work"."OdhPoly" USING gist ("Geometry");

ALTER TABLE "work"."OdhPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."OdhPoly" TO mggt;
GRANT ALL ON TABLE "work"."OdhPoly" TO postgres;
GRANT ALL ON TABLE "work"."OdhPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."OdhPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."OdhPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."OdhPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."OdhPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."OdhPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."OdhPoly" IS 'Объект дорожного хозяйства (паспорт)';
COMMENT ON COLUMN "work"."OdhPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."OdhPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."OdhPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."OdhPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."OdhPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."OdhPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."OdhPoly"."Name" IS 'Наименование объекта';
COMMENT ON COLUMN "work"."OdhPoly"."OwnerLegalPersonId" IS 'ID балансодержателя';
COMMENT ON COLUMN "work"."OdhPoly"."OwnerLegalPersonVersionId" IS 'Версия балансодержателя';
COMMENT ON COLUMN "work"."OdhPoly"."OwnerStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."OdhPoly"."OwnerEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."OdhPoly"."GrbsLegalPersonId" IS 'ID учредителя/ГРБС';
COMMENT ON COLUMN "work"."OdhPoly"."GrbsLegalPersonVersionId" IS 'Версия учредителя/ГРБС';
COMMENT ON COLUMN "work"."OdhPoly"."GrbsStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."OdhPoly"."GrbsEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."OdhPoly"."CustomerLegalPersonId" IS 'ID заказчика';
COMMENT ON COLUMN "work"."OdhPoly"."CustomerLegalPersonVersionId" IS 'Версия заказчика';
COMMENT ON COLUMN "work"."OdhPoly"."CustomerStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."OdhPoly"."CustomertEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."OdhPoly"."CleanCategory" IS 'Категория по уборке';
COMMENT ON COLUMN "work"."OdhPoly"."CleanSubcategory" IS 'Подкатегория по уборке';
COMMENT ON COLUMN "work"."OdhPoly"."Intensity" IS 'Данные о интенсивности движения';
COMMENT ON COLUMN "work"."OdhPoly"."CategorySp" IS 'Код категории по СП 42.13330.2016';
COMMENT ON COLUMN "work"."OdhPoly"."PassportDraftOrg" IS 'Составитель паспорта';
COMMENT ON COLUMN "work"."OdhPoly"."PassportDate" IS 'Дата составления/согласования паспорта';
COMMENT ON COLUMN "work"."OdhPoly"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."OdhPoly"."Distance" IS 'Протяженность по оси, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."LayoutLength" IS 'Протяженность объекта по всем осям, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."AxisLength" IS 'Протяженность осевой разделительной линии, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."SnowArea" IS 'Площадь вывоза снега, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."RotorArea" IS 'Площадь роторной перекидки, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."ReagentArea" IS 'Площадь обработки реагентами, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."ActualSchemaDate" IS 'Дата актуализации плана-схемы';
COMMENT ON COLUMN "work"."OdhPoly"."IsDiffHeightMark" IS 'Признак «Разновысотный ОГХ»';
COMMENT ON COLUMN "work"."OdhPoly"."InboundArea" IS 'Общая площадь в границах ОДХ, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."TotalArea" IS 'Общая площадь в ТС, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."TpuArea" IS 'Общая площадь ТПУ, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."GuttersLength" IS 'Протяженность лотков, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."RoadwayArea" IS 'Проезжая часть всего, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."MarginArea" IS 'Обочины, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."FootwayArea" IS 'Тротуары, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."BoundStoneLength" IS 'Бортовой камень, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."TramRailsLength" IS 'Трамвайные пути, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."TrafficSignsQty" IS 'Дорожные знаки, указатели и информационные указатели, шт.';
COMMENT ON COLUMN "work"."OdhPoly"."TraffLightQty" IS 'Светофорные объекты, шт.';
COMMENT ON COLUMN "work"."OdhPoly"."StationQty" IS 'Остановки общественного транспорта, шт.';
COMMENT ON COLUMN "work"."OdhPoly"."GuidingArea" IS 'Ограждения, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."GuidingLength" IS 'Ограждения, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."GuidingQty" IS 'Ограждения, шт.';
COMMENT ON COLUMN "work"."OdhPoly"."OtherArea" IS 'Прочие территории, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."EnginQty" IS 'Инженерные сооружения, шт';
COMMENT ON COLUMN "work"."OdhPoly"."BicycleArea" IS 'Общая площадь велодорожек, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."BicycleLength" IS 'Протяженность по пикетажным осям велодорожек, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."CleaningArea" IS 'Площадь уборки, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."RoadwayNoprkgManualCleanArea" IS 'Площадь ручной уборки проезжей части (без парковочного пространства), кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."RoadwayNoprkgAutoCleanArea" IS 'Площадь механизированной уборки проезжей части (без парковочного пространства), кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."RoadwayPrkgManualCleanArea" IS 'Площадь ручной уборки парковочного пространства, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."RoadwayPrkgAutoCleanArea" IS 'Площадь механизированной уборки парковочного пространства, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."AutoFootwayArea" IS 'Площадь уборки тротуаров мех., кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."ManualFootwayArea" IS 'Площадь уборки тротуаров ручн., кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."StationNumber" IS 'Количество убираемых остановок, ед.';
COMMENT ON COLUMN "work"."OdhPoly"."StationArea" IS 'Площадь убираемых остановок, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."BarNewJersey" IS 'Стенка Нью-Джерси, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."Buffer" IS 'Буфер безопасности, ед.';
COMMENT ON COLUMN "work"."OdhPoly"."Asperity" IS 'ИДН, ед.';
COMMENT ON COLUMN "work"."OdhPoly"."Sign" IS 'Знаки, ед.';
COMMENT ON COLUMN "work"."OdhPoly"."Info" IS 'Информационные щиты, ед.';
COMMENT ON COLUMN "work"."OdhPoly"."CleaningGuidingLength" IS 'Ограждения, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."CleaningGuidingArea" IS 'Ограждения, кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."CleaningGuidingQty" IS 'Ограждения, шт.';
COMMENT ON COLUMN "work"."OdhPoly"."BarAntinoise" IS 'Защитная стенка, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."Pointer" IS 'Дорожные указатели, ед.';
COMMENT ON COLUMN "work"."OdhPoly"."NavigationPointer" IS 'Навигационный указатель, ед.';
COMMENT ON COLUMN "work"."OdhPoly"."BarWave" IS 'Металлические барьерные ограждения Волна, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."BarTrans" IS 'Металлические барьерные ограждения Трансэкострой, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."BarPipe" IS 'Металлические барьерные ограждения Труба, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."FootwayPole" IS 'Тротуарные столбики, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."BarFracasso" IS 'Металлическое барьерное ограждение Фракассо, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."BarConcrete" IS 'Бетонный парапет, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."BarFoot" IS 'Пешеходные ограждения, п.м';
COMMENT ON COLUMN "work"."OdhPoly"."MarginAutoCleanArea" IS 'Площадь уборки обочин, мех., кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."MarginManualCleanArea" IS 'Площадь уборки обочин, руч., кв.м';
COMMENT ON COLUMN "work"."OdhPoly"."RepairsInfoList" IS 'Перечень ремонтных работ';
COMMENT ON COLUMN "work"."OdhPoly"."RepairsInfoListPlan" IS 'Перечень проектных работ';
COMMENT ON COLUMN "work"."OdhPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."OdhPoly"."Tree" IS 'Перечень дочерних объектов';
COMMENT ON COLUMN "work"."OdhPoly"."TrafficCharacterList" IS 'Характеристика движения';
COMMENT ON COLUMN "work"."OdhPoly"."CreateType" IS 'Тип создания';
COMMENT ON COLUMN "work"."OdhPoly"."PassDevInitiator" IS 'Инициатор разработки паспорта';
COMMENT ON COLUMN "work"."OdhPoly"."DateSurvey" IS 'Дата обследования территории';
COMMENT ON COLUMN "work"."OdhPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."OdhPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."OdhPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."OdhPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."OdhPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."OdhPoly"."PassBrId" IS 'Номер заявки на обследование';
COMMENT ON COLUMN "work"."OdhPoly"."Landscaping" IS 'Работы по благоустройству';
COMMENT ON COLUMN "work"."OdhPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Инженерные сооружения (Точка)
CREATE TABLE IF NOT EXISTS "work"."OtherEnginConstructPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "EngineStructType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "Area" float8 NULL,
    "IsObjectArea" bool NULL,
    "Quantity" float8 NULL,
    "GuttersLength" float8 NULL,
    -- Удалено в новой версии
    -- "Placement" text NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "OtherEnginConstructPoint_Geom_idx" ON "work"."OtherEnginConstructPoint" USING gist ("Geometry");

ALTER TABLE "work"."OtherEnginConstructPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."OtherEnginConstructPoint" TO mggt;
GRANT ALL ON TABLE "work"."OtherEnginConstructPoint" TO postgres;
GRANT ALL ON TABLE "work"."OtherEnginConstructPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."OtherEnginConstructPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."OtherEnginConstructPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."OtherEnginConstructPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."OtherEnginConstructPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."OtherEnginConstructPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."OtherEnginConstructPoint" IS 'Инженерные сооружения (Точка)';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."EngineStructType" IS 'Код типа инженерного сооружения';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."Area" IS 'Площадь (в плане)';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."IsObjectArea" IS 'Входит в общую площадь ОДХ';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."Quantity" IS 'Количество, шт.';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."GuttersLength" IS 'Двухметровая прилотковая зона, п.м.';
-- Удалено в новой версии
-- COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."Placement" IS 'Код места размещения';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."OtherEnginConstructPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Инженерные сооружения (Полигон)
CREATE TABLE IF NOT EXISTS "work"."OtherEnginConstructPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "EngineStructType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "Area" float8 NULL,
    "IsObjectArea" bool NULL,
    "Quantity" float8 NULL,
    "GuttersLength" float8 NULL,
    -- Удалено в новой версии
    -- "Placement" text NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL,
    "AxisGeometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "OtherEnginConstructPoly_Geom_idx" ON "work"."OtherEnginConstructPoly" USING gist ("Geometry");
CREATE INDEX IF NOT EXISTS "OtherEnginConstructPoly_AxisGeom_idx" ON "work"."OtherEnginConstructPoly" USING gist ("AxisGeometry");

ALTER TABLE "work"."OtherEnginConstructPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."OtherEnginConstructPoly" TO mggt;
GRANT ALL ON TABLE "work"."OtherEnginConstructPoly" TO postgres;
GRANT ALL ON TABLE "work"."OtherEnginConstructPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."OtherEnginConstructPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."OtherEnginConstructPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."OtherEnginConstructPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."OtherEnginConstructPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."OtherEnginConstructPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."OtherEnginConstructPoly" IS 'Инженерные сооружения (Полигон)';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."EngineStructType" IS 'Код типа инженерного сооружения';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."Area" IS 'Площадь (в плане)';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."IsObjectArea" IS 'Входит в общую площадь ОДХ';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."Quantity" IS 'Количество, шт.';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."GuttersLength" IS 'Двухметровая прилотковая зона, п.м.';
-- Удалено в новой версии
-- COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."Placement" IS 'Код места размещения';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."Geometry" IS 'Геометрия объекта';
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."AxisGeometry" IS 'Геометрия осевой линии объекта';


-- Создаём Прочие территории
CREATE TABLE IF NOT EXISTS "work"."OtherFlatBuildingPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "FlatElementType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "CoatingType" text NULL,
    "CoatingGroup" text NULL,
    "Area" float8 NULL,
    "IsRoadwayArea" bool NULL,
    "IsFootwayArea" bool NULL,
    "AutoCleanArea" float8 NULL,
    "ManualCleanArea" float8 NULL,
    "NoCleanArea" float8 NULL,
    "Description" text NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL,
    "AxisGeometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "OtherFlatBuildingPoly_Geom_idx" ON "work"."OtherFlatBuildingPoly" USING gist ("Geometry");
CREATE INDEX IF NOT EXISTS "OtherFlatBuildingPoly_AxisGeom_idx" ON "work"."OtherFlatBuildingPoly" USING gist ("AxisGeometry");

ALTER TABLE "work"."OtherFlatBuildingPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."OtherFlatBuildingPoly" TO mggt;
GRANT ALL ON TABLE "work"."OtherFlatBuildingPoly" TO postgres;
GRANT ALL ON TABLE "work"."OtherFlatBuildingPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."OtherFlatBuildingPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."OtherFlatBuildingPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."OtherFlatBuildingPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."OtherFlatBuildingPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."OtherFlatBuildingPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."OtherFlatBuildingPoly" IS 'Прочие территории';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."FlatElementType" IS 'Код типа прочей территории';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."CoatingType" IS 'Код наименования вида покрытия (Вид покрытия, уточнение)';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."CoatingGroup" IS 'Код группы покрытия (Вид покрытия)';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."Area" IS 'Площадь, кв. м.';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."IsRoadwayArea" IS 'Способ уборки – относится к проезжей части';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."IsFootwayArea" IS 'Способ уборки – относится к тротуару';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."AutoCleanArea" IS 'Площадь уборки мех., кв.м';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."ManualCleanArea" IS 'Площадь уборки ручн., кв.м';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."NoCleanArea" IS 'Площадь без уборки, кв.м';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."Geometry" IS 'Геометрия объекта';
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."AxisGeometry" IS 'Геометрия осевой линии объекта';


-- Создаём Иной объект капитального строительства
CREATE TABLE IF NOT EXISTS "work"."OtherOksPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "BuildingsType" text NULL,
    "BuildingsTypeSpec" text NULL,
    "Property" text NULL,
    "Area" float8 NULL,
    "CoatingGroup" text NULL,
    "CoatingType" text NULL,
    "CoatingFaceType" text NULL,
    "FaceArea" float8 NULL,
    "Unom" int8 NULL,
    "Unad" int8 NULL,
	"FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsSmmCleaning" bool NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "OtherOksPoly_Geom_idx" ON "work"."OtherOksPoly" USING gist ("Geometry");

ALTER TABLE "work"."OtherOksPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."OtherOksPoly" TO mggt;
GRANT ALL ON TABLE "work"."OtherOksPoly" TO postgres;
GRANT ALL ON TABLE "work"."OtherOksPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."OtherOksPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."OtherOksPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."OtherOksPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."OtherOksPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."OtherOksPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."OtherOksPoly" IS 'Иной объект капитального строительства';
COMMENT ON COLUMN "work"."OtherOksPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."OtherOksPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."OtherOksPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."OtherOksPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."OtherOksPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."OtherOksPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."OtherOksPoly"."BuildingsType" IS 'Код назначения';
COMMENT ON COLUMN "work"."OtherOksPoly"."BuildingsTypeSpec" IS 'Код уточнения назначения';
COMMENT ON COLUMN "work"."OtherOksPoly"."Property" IS 'Характеристика';
COMMENT ON COLUMN "work"."OtherOksPoly"."Area" IS 'Площадь кв.м';
COMMENT ON COLUMN "work"."OtherOksPoly"."CoatingGroup" IS 'Код вида покрытия';
COMMENT ON COLUMN "work"."OtherOksPoly"."CoatingType" IS 'Код вида покрытия (уточнение)';
COMMENT ON COLUMN "work"."OtherOksPoly"."CoatingFaceType" IS 'Код вида покрытия (облицовка)';
COMMENT ON COLUMN "work"."OtherOksPoly"."FaceArea" IS 'Площадь облицовки, кв.м.';
COMMENT ON COLUMN "work"."OtherOksPoly"."Unom" IS 'Данные об УНОМ';
COMMENT ON COLUMN "work"."OtherOksPoly"."Unad" IS 'Данные об УНАД';
COMMENT ON COLUMN "work"."OtherOksPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."OtherOksPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."OtherOksPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."OtherOksPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."OtherOksPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."OtherOksPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."OtherOksPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."OtherOksPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."OtherOksPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."OtherOksPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."OtherOksPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."OtherOksPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."OtherOksPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."OtherOksPoly"."IsSmmCleaning" IS 'Признак «Уборка с применением СММ»';
COMMENT ON COLUMN "work"."OtherOksPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Иные некапитальные объекты
CREATE TABLE IF NOT EXISTS "work"."OtherTechPlacePoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "BuildingsType" text NULL,
    "BuildingsTypeSpec" text NULL,
    "Material" text NULL,
    "Area" float8 NULL,
    "AbutmentTypeList" text NULL,
    "Unom" int8 NULL,
    "Unad" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "OtherTechPlacePoly_Geom_idx" ON "work"."OtherTechPlacePoly" USING gist ("Geometry");

ALTER TABLE "work"."OtherTechPlacePoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."OtherTechPlacePoly" TO mggt;
GRANT ALL ON TABLE "work"."OtherTechPlacePoly" TO postgres;
GRANT ALL ON TABLE "work"."OtherTechPlacePoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."OtherTechPlacePoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."OtherTechPlacePoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."OtherTechPlacePoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."OtherTechPlacePoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."OtherTechPlacePoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."OtherTechPlacePoly" IS 'Иные некапитальные объекты';
COMMENT ON COLUMN "work"."OtherTechPlacePoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."BuildingsType" IS 'Код назначения';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."BuildingsTypeSpec" IS 'Код уточнения назначения';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."Area" IS 'Площадь кв.м';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."AbutmentTypeList" IS 'Элементы сопряжения';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."Unom" IS 'Данные UNOM';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."Unad" IS 'Данные UNAD';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."OtherTechPlacePoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Объект озеленения
CREATE TABLE IF NOT EXISTS "work"."OznPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "Name" text NULL,
    "OwnerLegalPersonId" int8 NULL,
    "OwnerLegalPersonVersionId" int8 NULL,
    "OwnerStartDate" timestamp NULL,
    "OwnerEndDate" timestamp NULL,
    "DepartmentLegalPersonId" int8 NULL,
    "DepartmentLegalPersonVersionId" int8 NULL,
    "DepartmentStartDate" timestamp NULL,
    "DepartmentEndDate" timestamp NULL,
    "CustomerLegalPersonId" int8 NULL,
    "CustomerLegalPersonVersionId" int8 NULL,
    "CustomerStartDate" timestamp NULL,
    "CustomertEndDate" timestamp NULL,
    "ImprovementCategory" text NULL,
    "ImprovementObjectCategory" text NULL,
    "PassportDraftOrg" text NULL,
    "PassportDate" timestamp NULL,
    "DateSurvey" timestamp NULL,
    "DateSurveyGreenZones" timestamp NULL,
    "Unom" int8 NULL,
    "Unad" int8 NULL,
    "TotalArea" float8 NULL,
    "TotalCleanArea" float8 NULL,
    "ManualCleanArea" float8 NULL,
    "AutoCleanArea" float8 NULL,
    "TotalCoverCleanArea" float8 NULL,
    "AsphaltCleanArea" float8 NULL,
    "SlabCleanArea" float8 NULL,
    "SoilCleanArea" float8 NULL,
    "RubberCleanArea" float8 NULL,
    "SandCleanArea" float8 NULL,
    "GraniteCleanArea" float8 NULL,
    "GrassCleanArea" float8 NULL,
    "PlasticCleanArea" float8 NULL,
    "GrassPaverCleanArea" float8 NULL,
    "TotalLawnArea" float8 NULL,
    "UsialLawnArea" float8 NULL,
    "ParterreLawnArea" float8 NULL,
    "LawnGridArea" float8 NULL,
    "LawnLawnArea" float8 NULL,
    "SlopeLawnArea" float8 NULL,
    "LawnOtherArea" float8 NULL,
    "CoverImproveAutoCleanArea" float8 NULL,
    "SnowCleanArea" float8 NULL,
    "ReservoirArea" float8 NULL,
    "RepairsInfoList" text NULL,
    "RepairsInfoListPlan" text NULL,
    "FileList" text NULL,
    "Tree" text NULL,
    "GreeningAddition" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "CreateType" text NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Okrug" text NULL,
    "District" text NULL,
	"PassBrId" int8 NULL,
	"Landscaping" text NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "OznPoly_Geom_idx" ON "work"."OznPoly" USING gist ("Geometry");

ALTER TABLE "work"."OznPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."OznPoly" TO mggt;
GRANT ALL ON TABLE "work"."OznPoly" TO postgres;
GRANT ALL ON TABLE "work"."OznPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."OznPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."OznPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."OznPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."OznPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."OznPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."OznPoly" IS 'Объект озеленения';
COMMENT ON COLUMN "work"."OznPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."OznPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."OznPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."OznPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."OznPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."OznPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."OznPoly"."Name" IS 'Наименование объекта';
COMMENT ON COLUMN "work"."OznPoly"."OwnerLegalPersonId" IS 'ID балансодержателя';
COMMENT ON COLUMN "work"."OznPoly"."OwnerLegalPersonVersionId" IS 'Версия балансодержателя';
COMMENT ON COLUMN "work"."OznPoly"."OwnerStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."OznPoly"."OwnerEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."OznPoly"."DepartmentLegalPersonId" IS 'ID ведомственного ОИВ';
COMMENT ON COLUMN "work"."OznPoly"."DepartmentLegalPersonVersionId" IS 'Версия ведомственного ОИВ';
COMMENT ON COLUMN "work"."OznPoly"."DepartmentStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."OznPoly"."DepartmentEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."OznPoly"."CustomerLegalPersonId" IS 'ID заказчика';
COMMENT ON COLUMN "work"."OznPoly"."CustomerLegalPersonVersionId" IS 'Версия заказчика';
COMMENT ON COLUMN "work"."OznPoly"."CustomerStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."OznPoly"."CustomertEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."OznPoly"."ImprovementCategory" IS 'Категория благоустройства';
COMMENT ON COLUMN "work"."OznPoly"."ImprovementObjectCategory" IS 'Категория озеленения';
COMMENT ON COLUMN "work"."OznPoly"."PassportDraftOrg" IS 'Исполнитель/Исполнители работ (по разработке, актуализации паспорта)';
COMMENT ON COLUMN "work"."OznPoly"."PassportDate" IS 'Дата составления';
COMMENT ON COLUMN "work"."OznPoly"."DateSurvey" IS 'Дата обследования территории';
COMMENT ON COLUMN "work"."OznPoly"."DateSurveyGreenZones" IS 'Дата обследования территории (дополнение сведений по ЗН)';
COMMENT ON COLUMN "work"."OznPoly"."Unom" IS 'Данные UNOM';
COMMENT ON COLUMN "work"."OznPoly"."Unad" IS 'Данные UNAD';
COMMENT ON COLUMN "work"."OznPoly"."TotalArea" IS 'Общая площадь объекта, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."TotalCleanArea" IS 'Общая уборочная площадь, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."ManualCleanArea" IS 'Площадь ручной уборки, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."AutoCleanArea" IS 'Площадь механизированной уборки, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."TotalCoverCleanArea" IS 'Общая уборочная площадь по покрытиям, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."AsphaltCleanArea" IS 'Асфальтобетонное, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."SlabCleanArea" IS 'Плиточное (Плитка или тактильная плитка), кв. м';
COMMENT ON COLUMN "work"."OznPoly"."SoilCleanArea" IS 'Грунтовое, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."RubberCleanArea" IS 'Мягкое из резиновой крошки, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."SandCleanArea" IS 'Мягкое из песка, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."GraniteCleanArea" IS 'Мягкое из гранитной высевки, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."GrassCleanArea" IS 'Мягкое из искусственной травы, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."PlasticCleanArea" IS 'Пластиковое, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."GrassPaverCleanArea" IS 'Газонная решетка (экопарковка), кв. м';
COMMENT ON COLUMN "work"."OznPoly"."TotalLawnArea" IS 'Общая площадь газонов, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."UsialLawnArea" IS 'Обыкновенный, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."ParterreLawnArea" IS 'Партерный, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."LawnGridArea" IS 'На ячеистом основании, экопарковки, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."LawnLawnArea" IS 'Луговой, разнотравный, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."SlopeLawnArea" IS 'На откосе, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."LawnOtherArea" IS 'Иного типа, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."CoverImproveAutoCleanArea" IS 'Территория уборки усовершенствованных покрытий, механизированная';
COMMENT ON COLUMN "work"."OznPoly"."SnowCleanArea" IS 'Площадь вывоза снега, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."ReservoirArea" IS 'Водоемы, кв. м';
COMMENT ON COLUMN "work"."OznPoly"."RepairsInfoList" IS 'Перечень ремонтных работ';
COMMENT ON COLUMN "work"."OznPoly"."RepairsInfoListPlan" IS 'Перечень проектных работ';
COMMENT ON COLUMN "work"."OznPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."OznPoly"."Tree" IS 'Перечень дочерних объектов';
COMMENT ON COLUMN "work"."OznPoly"."GreeningAddition" IS 'Признак «Требует дополнения по зеленым насаждениям»';
COMMENT ON COLUMN "work"."OznPoly"."IsDiffHeightMark" IS 'Признак «Разновысотный ОГХ»';
COMMENT ON COLUMN "work"."OznPoly"."CreateType" IS 'Тип создания';
COMMENT ON COLUMN "work"."OznPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."OznPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."OznPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."OznPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."OznPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."OznPoly"."Okrug" IS 'Округ';
COMMENT ON COLUMN "work"."OznPoly"."District" IS 'Район';
COMMENT ON COLUMN "work"."OznPoly"."PassBrId" IS 'Номер заявки на обследование';
COMMENT ON COLUMN "work"."OznPoly"."Landscaping" IS 'Работы по благоустройству';
COMMENT ON COLUMN "work"."OznPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Плоскостные сооружения
CREATE TABLE IF NOT EXISTS "work"."PlanarStructurePoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "PlanarStructureType" text NULL,
    "PlanarStructureTypeRef" text NULL,
    "CoatingType" text NULL,
    "CoatingGroup" text NULL,
    "TotalArea" float8 NULL,
    "ManualCleanArea" float8 NULL,
    "AutoCleanArea" float8 NULL,
    "Property" text NULL,
    "AbutmentTypeList" text NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "GroupId" int8 NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"ParkingPlacesQuantity" int8 NULL,
    "IceRinkPlanarStructure" bool NULL,
    "IsSmmCleaning" bool NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "PlanarStructurePoly_Geom_idx" ON "work"."PlanarStructurePoly" USING gist ("Geometry");

ALTER TABLE "work"."PlanarStructurePoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."PlanarStructurePoly" TO mggt;
GRANT ALL ON TABLE "work"."PlanarStructurePoly" TO postgres;
GRANT ALL ON TABLE "work"."PlanarStructurePoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."PlanarStructurePoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."PlanarStructurePoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."PlanarStructurePoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."PlanarStructurePoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."PlanarStructurePoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."PlanarStructurePoly" IS 'Плоскостные сооружения';
COMMENT ON COLUMN "work"."PlanarStructurePoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."PlanarStructureType" IS 'Код назначения';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."PlanarStructureTypeRef" IS 'Код уточнения';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."CoatingType" IS 'Код наименования вида покрытия (Вид покрытия, уточнение)';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."CoatingGroup" IS 'Код группы покрытия (Вид покрытия)';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."TotalArea" IS 'Площадь кв.м';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."ManualCleanArea" IS 'Площадь уборки ручн., кв.м';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."AutoCleanArea" IS 'Площадь уборки мех., кв.м';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."Property" IS 'Характеристика';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."AbutmentTypeList" IS 'Элементы сопряжения';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."GroupId" IS 'Является частью составного объекта';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."ParkingPlacesQuantity" IS 'Количество машиномест';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."IceRinkPlanarStructure" IS 'Каток открытый с естественным льдом на существующей спортивной площадке спортивного типа';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."IsSmmCleaning" IS 'Признак «Уборка с применением СММ»';
COMMENT ON COLUMN "work"."PlanarStructurePoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Элементы благоустройства для маломобильных групп населения (Линия)
CREATE TABLE IF NOT EXISTS "work"."PpiLine"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ArrangeElementType" text NULL,
    "Quantity" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "ZoneOghObjectType" text NULL,
    "ZoneOghObjectRootId" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "PpiLine_Geom_idx" ON "work"."PpiLine" USING gist ("Geometry");

ALTER TABLE "work"."PpiLine" OWNER to postgres;
GRANT ALL ON TABLE "work"."PpiLine" TO mggt;
GRANT ALL ON TABLE "work"."PpiLine" TO postgres;
GRANT ALL ON TABLE "work"."PpiLine" TO mggt_editor;
GRANT SELECT ON TABLE "work"."PpiLine" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."PpiLine_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."PpiLine_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."PpiLine_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."PpiLine_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."PpiLine" IS 'Элементы благоустройства для маломобильных групп населения (Линия)';
COMMENT ON COLUMN "work"."PpiLine".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."PpiLine"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."PpiLine"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."PpiLine"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."PpiLine"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."PpiLine"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."PpiLine"."ArrangeElementType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."PpiLine"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."PpiLine"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."PpiLine"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."PpiLine"."ZoneOghObjectType" IS 'Код типа объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."PpiLine"."ZoneOghObjectRootId" IS 'Идентификатор объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."PpiLine"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."PpiLine"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."PpiLine"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."PpiLine"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."PpiLine"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."PpiLine"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."PpiLine"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."PpiLine"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."PpiLine"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."PpiLine"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."PpiLine"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."PpiLine"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."PpiLine"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."PpiLine"."Geometry" IS 'Геометрия объекта';


-- Создаём Элементы благоустройства для маломобильных групп населения (Точка)
CREATE TABLE IF NOT EXISTS "work"."PpiPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ArrangeElementType" text NULL,
    "Quantity" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "ZoneOghObjectType" text NULL,
    "ZoneOghObjectRootId" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "PpiPoint_Geom_idx" ON "work"."PpiPoint" USING gist ("Geometry");

ALTER TABLE "work"."PpiPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."PpiPoint" TO mggt;
GRANT ALL ON TABLE "work"."PpiPoint" TO postgres;
GRANT ALL ON TABLE "work"."PpiPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."PpiPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."PpiPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."PpiPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."PpiPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."PpiPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."PpiPoint" IS 'Элементы благоустройства для маломобильных групп населения (Точка)';
COMMENT ON COLUMN "work"."PpiPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."PpiPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."PpiPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."PpiPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."PpiPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."PpiPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."PpiPoint"."ArrangeElementType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."PpiPoint"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."PpiPoint"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."PpiPoint"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."PpiPoint"."ZoneOghObjectType" IS 'Код типа объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."PpiPoint"."ZoneOghObjectRootId" IS 'Идентификатор объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."PpiPoint"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."PpiPoint"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."PpiPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."PpiPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."PpiPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."PpiPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."PpiPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."PpiPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."PpiPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."PpiPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."PpiPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."PpiPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."PpiPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."PpiPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Элементы благоустройства для маломобильных групп населения (Полигон)
CREATE TABLE IF NOT EXISTS "work"."PpiPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ArrangeElementType" text NULL,
    "Quantity" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "ZoneOghObjectType" text NULL,
    "ZoneOghObjectRootId" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "PpiPoly_Geom_idx" ON "work"."PpiPoly" USING gist ("Geometry");

ALTER TABLE "work"."PpiPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."PpiPoly" TO mggt;
GRANT ALL ON TABLE "work"."PpiPoly" TO postgres;
GRANT ALL ON TABLE "work"."PpiPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."PpiPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."PpiPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."PpiPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."PpiPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."PpiPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."PpiPoly" IS 'Элементы благоустройства для маломобильных групп населения (Полигон)';
COMMENT ON COLUMN "work"."PpiPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."PpiPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."PpiPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."PpiPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."PpiPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."PpiPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."PpiPoly"."ArrangeElementType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."PpiPoly"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."PpiPoly"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."PpiPoly"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."PpiPoly"."ZoneOghObjectType" IS 'Код типа объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."PpiPoly"."ZoneOghObjectRootId" IS 'Идентификатор объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."PpiPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."PpiPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."PpiPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."PpiPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."PpiPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."PpiPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."PpiPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."PpiPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."PpiPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."PpiPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."PpiPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."PpiPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."PpiPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."PpiPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Растения Красной книги
CREATE TABLE IF NOT EXISTS "work"."RedBookPlantPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "RedBookPlant" text NULL,
    "SectionNum" int8 NULL,
    "GreenNum" int8 NULL,
    "NoCalc" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "RedBookPlantPoint_Geom_idx" ON "work"."RedBookPlantPoint" USING gist ("Geometry");

ALTER TABLE "work"."RedBookPlantPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."RedBookPlantPoint" TO mggt;
GRANT ALL ON TABLE "work"."RedBookPlantPoint" TO postgres;
GRANT ALL ON TABLE "work"."RedBookPlantPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."RedBookPlantPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."RedBookPlantPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."RedBookPlantPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."RedBookPlantPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."RedBookPlantPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."RedBookPlantPoint" IS 'Растения Красной книги';
COMMENT ON COLUMN "work"."RedBookPlantPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."RedBookPlant" IS 'Код вида растения';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."SectionNum" IS 'Номер участка';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."GreenNum" IS 'Номер растения';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."RedBookPlantPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Элементы организации рельефа (Линия)
CREATE TABLE IF NOT EXISTS "work"."ReliefLine"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ArrangeElementType" text NULL,
    "Quantity" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "ZoneOghObjectType" text NULL,
    "ZoneOghObjectRootId" int8 NULL,
    "CoatingGroup" text NULL,
    "CoatingType" text NULL,
    "CoatingFaceType" text NULL,
    "FaceArea" float8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "ReliefLine_Geom_idx" ON "work"."ReliefLine" USING gist ("Geometry");

ALTER TABLE "work"."ReliefLine" OWNER to postgres;
GRANT ALL ON TABLE "work"."ReliefLine" TO mggt;
GRANT ALL ON TABLE "work"."ReliefLine" TO postgres;
GRANT ALL ON TABLE "work"."ReliefLine" TO mggt_editor;
GRANT SELECT ON TABLE "work"."ReliefLine" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."ReliefLine_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."ReliefLine_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."ReliefLine_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."ReliefLine_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."ReliefLine" IS 'Элементы организации рельефа (Линия)';
COMMENT ON COLUMN "work"."ReliefLine".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."ReliefLine"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."ReliefLine"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."ReliefLine"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."ReliefLine"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."ReliefLine"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."ReliefLine"."ArrangeElementType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."ReliefLine"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."ReliefLine"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."ReliefLine"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."ReliefLine"."ZoneOghObjectType" IS 'Тип объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."ReliefLine"."ZoneOghObjectRootId" IS 'Идентификатор объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."ReliefLine"."CoatingGroup" IS 'Код вида покрытия';
COMMENT ON COLUMN "work"."ReliefLine"."CoatingType" IS 'Код вида покрытия (уточнение)';
COMMENT ON COLUMN "work"."ReliefLine"."CoatingFaceType" IS 'Код вида покрытия (облицовка)';
COMMENT ON COLUMN "work"."ReliefLine"."FaceArea" IS 'Площадь облицовки, кв.м.';
COMMENT ON COLUMN "work"."ReliefLine"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."ReliefLine"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."ReliefLine"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."ReliefLine"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."ReliefLine"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."ReliefLine"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."ReliefLine"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."ReliefLine"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."ReliefLine"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."ReliefLine"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."ReliefLine"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."ReliefLine"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."ReliefLine"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."ReliefLine"."Geometry" IS 'Геометрия объекта';


-- Создаём Элементы организации рельефа (Точка)
CREATE TABLE IF NOT EXISTS "work"."ReliefPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ArrangeElementType" text NULL,
    "Quantity" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "ZoneOghObjectType" text NULL,
    "ZoneOghObjectRootId" int8 NULL,
    "CoatingGroup" text NULL,
    "CoatingType" text NULL,
    "CoatingFaceType" text NULL,
    "FaceArea" float8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "ReliefPoint_Geom_idx" ON "work"."ReliefPoint" USING gist ("Geometry");

ALTER TABLE "work"."ReliefPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."ReliefPoint" TO mggt;
GRANT ALL ON TABLE "work"."ReliefPoint" TO postgres;
GRANT ALL ON TABLE "work"."ReliefPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."ReliefPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."ReliefPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."ReliefPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."ReliefPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."ReliefPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."ReliefPoint" IS 'Элементы организации рельефа (Точка)';
COMMENT ON COLUMN "work"."ReliefPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."ReliefPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."ReliefPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."ReliefPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."ReliefPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."ReliefPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."ReliefPoint"."ArrangeElementType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."ReliefPoint"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."ReliefPoint"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."ReliefPoint"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."ReliefPoint"."ZoneOghObjectType" IS 'Тип объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."ReliefPoint"."ZoneOghObjectRootId" IS 'Идентификатор объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."ReliefPoint"."CoatingGroup" IS 'Код вида покрытия';
COMMENT ON COLUMN "work"."ReliefPoint"."CoatingType" IS 'Код вида покрытия (уточнение)';
COMMENT ON COLUMN "work"."ReliefPoint"."CoatingFaceType" IS 'Код вида покрытия (облицовка)';
COMMENT ON COLUMN "work"."ReliefPoint"."FaceArea" IS 'Площадь облицовки, кв.м.';
COMMENT ON COLUMN "work"."ReliefPoint"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."ReliefPoint"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."ReliefPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."ReliefPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."ReliefPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."ReliefPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."ReliefPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."ReliefPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."ReliefPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."ReliefPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."ReliefPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."ReliefPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."ReliefPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."ReliefPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Элементы организации рельефа (Полигон)
CREATE TABLE IF NOT EXISTS "work"."ReliefPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ArrangeElementType" text NULL,
    "Quantity" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "ZoneOghObjectType" text NULL,
    "ZoneOghObjectRootId" int8 NULL,
    "CoatingGroup" text NULL,
    "CoatingType" text NULL,
    "CoatingFaceType" text NULL,
    "FaceArea" float8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "ReliefPoly_Geom_idx" ON "work"."ReliefPoly" USING gist ("Geometry");

ALTER TABLE "work"."ReliefPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."ReliefPoly" TO mggt;
GRANT ALL ON TABLE "work"."ReliefPoly" TO postgres;
GRANT ALL ON TABLE "work"."ReliefPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."ReliefPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."ReliefPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."ReliefPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."ReliefPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."ReliefPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."ReliefPoly" IS 'Элементы организации рельефа (Полигон)';
COMMENT ON COLUMN "work"."ReliefPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."ReliefPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."ReliefPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."ReliefPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."ReliefPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."ReliefPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."ReliefPoly"."ArrangeElementType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."ReliefPoly"."Quantity" IS 'Количество';
COMMENT ON COLUMN "work"."ReliefPoly"."Unit" IS 'Код единицы измерения';
COMMENT ON COLUMN "work"."ReliefPoly"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."ReliefPoly"."ZoneOghObjectType" IS 'Тип объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."ReliefPoly"."ZoneOghObjectRootId" IS 'Идентификатор объекта, на котором расположен МАФ';
COMMENT ON COLUMN "work"."ReliefPoly"."CoatingGroup" IS 'Код вида покрытия';
COMMENT ON COLUMN "work"."ReliefPoly"."CoatingType" IS 'Код вида покрытия (уточнение)';
COMMENT ON COLUMN "work"."ReliefPoly"."CoatingFaceType" IS 'Код вида покрытия (облицовка)';
COMMENT ON COLUMN "work"."ReliefPoly"."FaceArea" IS 'Площадь облицовки, кв.м.';
COMMENT ON COLUMN "work"."ReliefPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."ReliefPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."ReliefPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."ReliefPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."ReliefPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."ReliefPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."ReliefPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."ReliefPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."ReliefPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."ReliefPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."ReliefPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."ReliefPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."ReliefPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."ReliefPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Знаки, указатели и информационные щиты
CREATE TABLE IF NOT EXISTS "work"."RoadSignsLine"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "EquipmentType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "Endwise" float8 NULL,
    "MountingMode" text NULL,
    "TrafficSignsCode" text NULL,
    "TrafficSignsName" text NULL,
    "Area" float8 NULL,
    "Height" float8 NULL,
    "Placement" text NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"SvgMarkerAngle" float4 NULL,
	"SvgMarkerPath" text NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(LineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "RoadSignsLine_Geom_idx" ON "work"."RoadSignsLine" USING gist ("Geometry");

ALTER TABLE "work"."RoadSignsLine" OWNER to postgres;
GRANT ALL ON TABLE "work"."RoadSignsLine" TO mggt;
GRANT ALL ON TABLE "work"."RoadSignsLine" TO postgres;
GRANT ALL ON TABLE "work"."RoadSignsLine" TO mggt_editor;
GRANT SELECT ON TABLE "work"."RoadSignsLine" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."RoadSignsLine_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."RoadSignsLine_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."RoadSignsLine_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."RoadSignsLine_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."RoadSignsLine" IS 'Знаки, указатели и информационные щиты';
COMMENT ON COLUMN "work"."RoadSignsLine".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."RoadSignsLine"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."RoadSignsLine"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."RoadSignsLine"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."RoadSignsLine"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."RoadSignsLine"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."RoadSignsLine"."EquipmentType" IS 'Код типа знака';
COMMENT ON COLUMN "work"."RoadSignsLine"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."RoadSignsLine"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."RoadSignsLine"."Endwise" IS 'По оси, м';
COMMENT ON COLUMN "work"."RoadSignsLine"."MountingMode" IS 'Код типа установки';
COMMENT ON COLUMN "work"."RoadSignsLine"."TrafficSignsCode" IS 'Код номера по ГОСТ';
COMMENT ON COLUMN "work"."RoadSignsLine"."TrafficSignsName" IS 'Код наименования';
COMMENT ON COLUMN "work"."RoadSignsLine"."Area" IS 'Площадь знака, указателя, кв.м';
COMMENT ON COLUMN "work"."RoadSignsLine"."Height" IS 'Высота расположения по низу, м';
COMMENT ON COLUMN "work"."RoadSignsLine"."Placement" IS 'Код местоположения';
COMMENT ON COLUMN "work"."RoadSignsLine"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."RoadSignsLine"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."RoadSignsLine"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."RoadSignsLine"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."RoadSignsLine"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."RoadSignsLine"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."RoadSignsLine"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."RoadSignsLine"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."RoadSignsLine"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."RoadSignsLine"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."RoadSignsLine"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."RoadSignsLine"."SvgMarkerAngle" IS 'Угол поворота SVG маркера знака';
COMMENT ON COLUMN "work"."RoadSignsLine"."SvgMarkerPath" IS 'Относительный путь к SVG маркеру знака в общей папке с дорожными знаками';
COMMENT ON COLUMN "work"."RoadSignsLine"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."RoadSignsLine"."Geometry" IS 'Геометрия объекта';


-- Создаём Тротуары
CREATE TABLE IF NOT EXISTS "work"."SidewalksPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "FlatElementType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "CoatingType" text NULL,
    "CoatingGroup" text NULL,
    "Area" float8 NULL,
    "Distance" float8 NULL,
    "WidthBegin" float8 NULL,
    "WidthEnd" float8 NULL,
    "AutoCleanArea" float8 NULL,
    "ManualCleanArea" float8 NULL,
    "NoCleanArea" float8 NULL,
    "OotCleanArea" float8 NULL,
    "UtnArea" float8 NULL,
    "Description" text NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL,
    "AxisGeometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "SidewalksPoly_Geom_idx" ON "work"."SidewalksPoly" USING gist ("Geometry");
CREATE INDEX IF NOT EXISTS "SidewalksPoly_AxisGeom_idx" ON "work"."SidewalksPoly" USING gist ("AxisGeometry");

ALTER TABLE "work"."SidewalksPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."SidewalksPoly" TO mggt;
GRANT ALL ON TABLE "work"."SidewalksPoly" TO postgres;
GRANT ALL ON TABLE "work"."SidewalksPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."SidewalksPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."SidewalksPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."SidewalksPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."SidewalksPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."SidewalksPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."SidewalksPoly" IS 'Тротуары';
COMMENT ON COLUMN "work"."SidewalksPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."SidewalksPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."SidewalksPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."SidewalksPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."SidewalksPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."SidewalksPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."SidewalksPoly"."FlatElementType" IS 'Код типа тротуара';
COMMENT ON COLUMN "work"."SidewalksPoly"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."SidewalksPoly"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."SidewalksPoly"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."SidewalksPoly"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."SidewalksPoly"."CoatingType" IS 'Код наименования вида покрытия (Вид покрытия, уточнение)';
COMMENT ON COLUMN "work"."SidewalksPoly"."CoatingGroup" IS 'Код группы покрытия (Вид покрытия)';
COMMENT ON COLUMN "work"."SidewalksPoly"."Area" IS 'Площадь, кв. м.';
COMMENT ON COLUMN "work"."SidewalksPoly"."Distance" IS 'Длина, п.м';
COMMENT ON COLUMN "work"."SidewalksPoly"."WidthBegin" IS 'Ширина в начале, м';
COMMENT ON COLUMN "work"."SidewalksPoly"."WidthEnd" IS 'Ширина в конце, м';
COMMENT ON COLUMN "work"."SidewalksPoly"."AutoCleanArea" IS 'Площадь уборки мех., кв.м';
COMMENT ON COLUMN "work"."SidewalksPoly"."ManualCleanArea" IS 'Площадь уборки ручн., кв.м';
COMMENT ON COLUMN "work"."SidewalksPoly"."NoCleanArea" IS 'Площадь без уборки, кв.м';
COMMENT ON COLUMN "work"."SidewalksPoly"."OotCleanArea" IS 'Площадь уборки посадочных площадок, кв.м';
COMMENT ON COLUMN "work"."SidewalksPoly"."UtnArea" IS 'УТН, кв.м';
COMMENT ON COLUMN "work"."SidewalksPoly"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."SidewalksPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."SidewalksPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."SidewalksPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."SidewalksPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."SidewalksPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."SidewalksPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."SidewalksPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."SidewalksPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."SidewalksPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."SidewalksPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."SidewalksPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."SidewalksPoly"."Geometry" IS 'Геометрия объекта';
COMMENT ON COLUMN "work"."SidewalksPoly"."AxisGeometry" IS 'Геометрия осевой линии объекта';


-- Создаём Особо охраняемые природные территории
CREATE TABLE IF NOT EXISTS "work"."SpaPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "Name" text NULL,
    "InventoryContractor" text NULL,
    "OwnerLegalPersonId" int8 NULL,
    "OwnerLegalPersonVersionId" int8 NULL,
    "OwnerStartDate" timestamp NULL,
    "OwnerEndDate" timestamp NULL,
    "DepartmentLegalPersonId" int8 NULL,
    "DepartmentLegalPersonVersionId" int8 NULL,
    "DepartmentStartDate" timestamp NULL,
    "DepartmentEndDate" timestamp NULL,
    "CustomerLegalPersonId" int8 NULL,
    "CustomerLegalPersonVersionId" int8 NULL,
    "CustomerStartDate" timestamp NULL,
    "CustomertEndDate" timestamp NULL,
    "CategorySpa" text NULL,
    "Unom" int8 NULL,
    "Unad" int8 NULL,
    "TotalArea" float8 NULL,
    "TotalCleanArea" float8 NULL,
    "ManualCleanArea" float8 NULL,
    "AutoCleanArea" float8 NULL,
    "TotalCoverCleanArea" float8 NULL,
    "AsphaltCleanArea" float8 NULL,
    "SlabCleanArea" float8 NULL,
    "SoilCleanArea" float8 NULL,
    "RubberCleanArea" float8 NULL,
    "SandCleanArea" float8 NULL,
    "GraniteCleanArea" float8 NULL,
    "GrassCleanArea" float8 NULL,
    "PlasticCleanArea" float8 NULL,
    "GrassPaverCleanArea" float8 NULL,
    "TotalLawnArea" float8 NULL,
    "UsialLawnArea" float8 NULL,
    "ParterreLawnArea" float8 NULL,
    "LawnGridArea" float8 NULL,
    "LawnLawnArea" float8 NULL,
    "SlopeLawnArea" float8 NULL,
    "LawnOtherArea" float8 NULL,
    "CoverImproveAutoCleanArea" float8 NULL,
    "SnowCleanArea" float8 NULL,
    "ReservoirArea" float8 NULL,
    "CowParsnipArea" float8 NULL,
    "MeadowLowlandArea" float8 NULL,
    "RepairsInfoList" text NULL,
    "RepairsInfoListPlan" text NULL,
    "FileList" text NULL,
    "Tree" text NULL,
    "IsDiffHeightMark" bool NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "SpaPoly_Geom_idx" ON "work"."SpaPoly" USING gist ("Geometry");

ALTER TABLE "work"."SpaPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."SpaPoly" TO mggt;
GRANT ALL ON TABLE "work"."SpaPoly" TO postgres;
GRANT ALL ON TABLE "work"."SpaPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."SpaPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."SpaPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."SpaPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."SpaPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."SpaPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."SpaPoly" IS 'Особо охраняемые природные территории';
COMMENT ON COLUMN "work"."SpaPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."SpaPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."SpaPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."SpaPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."SpaPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."SpaPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."SpaPoly"."Name" IS 'Наименование объекта';
COMMENT ON COLUMN "work"."SpaPoly"."InventoryContractor" IS 'Исполнитель работ по инвентаризации';
COMMENT ON COLUMN "work"."SpaPoly"."OwnerLegalPersonId" IS 'ID балансодержателя';
COMMENT ON COLUMN "work"."SpaPoly"."OwnerLegalPersonVersionId" IS 'Версия балансодержателя';
COMMENT ON COLUMN "work"."SpaPoly"."OwnerStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."SpaPoly"."OwnerEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."SpaPoly"."DepartmentLegalPersonId" IS 'ID ведомственного ОИВ';
COMMENT ON COLUMN "work"."SpaPoly"."DepartmentLegalPersonVersionId" IS 'Версия ведомственного ОИВ';
COMMENT ON COLUMN "work"."SpaPoly"."DepartmentStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."SpaPoly"."DepartmentEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."SpaPoly"."CustomerLegalPersonId" IS 'ID заказчика';
COMMENT ON COLUMN "work"."SpaPoly"."CustomerLegalPersonVersionId" IS 'Версия заказчика';
COMMENT ON COLUMN "work"."SpaPoly"."CustomerStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."SpaPoly"."CustomertEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."SpaPoly"."CategorySpa" IS 'Категория благоустройства';
COMMENT ON COLUMN "work"."SpaPoly"."Unom" IS 'Данные UNOM';
COMMENT ON COLUMN "work"."SpaPoly"."Unad" IS 'Данные UNAD';
COMMENT ON COLUMN "work"."SpaPoly"."TotalArea" IS 'Общая площадь объекта, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."TotalCleanArea" IS 'Общая уборочная площадь, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."ManualCleanArea" IS 'Площадь ручной уборки, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."AutoCleanArea" IS 'Площадь механизированной уборки, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."TotalCoverCleanArea" IS 'Общая уборочная площадь по покрытиям, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."AsphaltCleanArea" IS 'Асфальтобетонное, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."SlabCleanArea" IS 'Плиточное (Плитка или тактильная плитка), кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."SoilCleanArea" IS 'Грунтовое, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."RubberCleanArea" IS 'Мягкое из резиновой крошки, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."SandCleanArea" IS 'Мягкое из песка, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."GraniteCleanArea" IS 'Мягкое из гранитной высевки, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."GrassCleanArea" IS 'Мягкое из искусственной травы, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."PlasticCleanArea" IS 'Пластиковое, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."GrassPaverCleanArea" IS 'Газонная решетка (экопарковка), кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."TotalLawnArea" IS 'Общая площадь газонов, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."UsialLawnArea" IS 'Обыкновенный, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."ParterreLawnArea" IS 'Партерный, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."LawnGridArea" IS 'На ячеистом основании, экопарковки, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."LawnLawnArea" IS 'Луговой, разнотравный, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."SlopeLawnArea" IS 'На откосе, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."LawnOtherArea" IS 'Иного типа, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."CoverImproveAutoCleanArea" IS 'Территория уборки усовершенствованных покрытий, механизированная';
COMMENT ON COLUMN "work"."SpaPoly"."SnowCleanArea" IS 'Площадь вывоза снега, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."ReservoirArea" IS 'Водоемы, кв. м';
COMMENT ON COLUMN "work"."SpaPoly"."CowParsnipArea" IS 'Участки, занятые борщевиком, кв.м';
COMMENT ON COLUMN "work"."SpaPoly"."MeadowLowlandArea" IS 'Луга и низины, кв.м';
COMMENT ON COLUMN "work"."SpaPoly"."RepairsInfoList" IS 'Перечень ремонтных работ';
COMMENT ON COLUMN "work"."SpaPoly"."RepairsInfoListPlan" IS 'Перечень проектных работ';
COMMENT ON COLUMN "work"."SpaPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."SpaPoly"."Tree" IS 'Перечень дочерних объектов';
COMMENT ON COLUMN "work"."SpaPoly"."IsDiffHeightMark" IS 'Признак «Разновысотный ОГХ»';
COMMENT ON COLUMN "work"."SpaPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."SpaPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."SpaPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."SpaPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."SpaPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."SpaPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Остановки общественного транспорта
CREATE TABLE IF NOT EXISTS "work"."StopsPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "ConvElementType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "Name" text NULL,
    "Quantity" float8 NULL,
    "Routes" text NULL,
    "Area" float8 NULL,
    "StationCleanArea" float8 NULL,
    "PocketArea" float8 NULL,
    "PavilionArea" float8 NULL,
    "Description" text NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL,
    "AxisGeometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "StopsPoly_Geom_idx" ON "work"."StopsPoly" USING gist ("Geometry");
CREATE INDEX IF NOT EXISTS "StopsPoly_AxisGeom_idx" ON "work"."StopsPoly" USING gist ("AxisGeometry");

ALTER TABLE "work"."StopsPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."StopsPoly" TO mggt;
GRANT ALL ON TABLE "work"."StopsPoly" TO postgres;
GRANT ALL ON TABLE "work"."StopsPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."StopsPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."StopsPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."StopsPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."StopsPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."StopsPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."StopsPoly" IS 'Остановки общественного транспорта';
COMMENT ON COLUMN "work"."StopsPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."StopsPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."StopsPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."StopsPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."StopsPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."StopsPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."StopsPoly"."ConvElementType" IS 'Код типа остановки';
COMMENT ON COLUMN "work"."StopsPoly"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."StopsPoly"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."StopsPoly"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."StopsPoly"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."StopsPoly"."Name" IS 'Название остановки (адресная привязка)';
COMMENT ON COLUMN "work"."StopsPoly"."Quantity" IS 'Количество павильонов, шт.';
COMMENT ON COLUMN "work"."StopsPoly"."Routes" IS 'Наличие маршрутов';
COMMENT ON COLUMN "work"."StopsPoly"."Area" IS 'Площадь посадочной площадки (включая павильон), кв.м';
COMMENT ON COLUMN "work"."StopsPoly"."StationCleanArea" IS 'Площадь уборки, кв.м.';
COMMENT ON COLUMN "work"."StopsPoly"."PocketArea" IS 'Площадь уширения типа кармана, кв.м';
COMMENT ON COLUMN "work"."StopsPoly"."PavilionArea" IS 'Площадь павильонов, кв.м';
COMMENT ON COLUMN "work"."StopsPoly"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."StopsPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."StopsPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."StopsPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."StopsPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."StopsPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."StopsPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."StopsPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."StopsPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."StopsPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."StopsPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."StopsPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."StopsPoly"."Geometry" IS 'Геометрия объекта';
COMMENT ON COLUMN "work"."StopsPoly"."AxisGeometry" IS 'Геометрия осевой линии объекта';


-- Создаём Велопарковки
CREATE TABLE IF NOT EXISTS "work"."StoragePlacePoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "BikeParkType" text NULL,
    "BikeRefType" text NULL,
    "Material" text NULL,
    "Area" float8 NULL,
    "CoatingGroup" text NULL,
    "CoatingType" text NULL,
    "AbutmentTypeList" text NULL,
    "MafsTypeList" text NULL,
    "Unom" int8 NULL,
    "Unad" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "StoragePlacePoly_Geom_idx" ON "work"."StoragePlacePoly" USING gist ("Geometry");

ALTER TABLE "work"."StoragePlacePoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."StoragePlacePoly" TO mggt;
GRANT ALL ON TABLE "work"."StoragePlacePoly" TO postgres;
GRANT ALL ON TABLE "work"."StoragePlacePoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."StoragePlacePoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."StoragePlacePoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."StoragePlacePoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."StoragePlacePoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."StoragePlacePoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."StoragePlacePoly" IS 'Велопарковки';
COMMENT ON COLUMN "work"."StoragePlacePoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."StoragePlacePoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."StoragePlacePoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."StoragePlacePoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."StoragePlacePoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."StoragePlacePoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."StoragePlacePoly"."BikeParkType" IS 'Код типа велопарковки';
COMMENT ON COLUMN "work"."StoragePlacePoly"."BikeRefType" IS 'Код уточнения типа велопарковки';
COMMENT ON COLUMN "work"."StoragePlacePoly"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."StoragePlacePoly"."Area" IS 'Площадь, кв.м.';
COMMENT ON COLUMN "work"."StoragePlacePoly"."CoatingGroup" IS 'Код вида покрытия';
COMMENT ON COLUMN "work"."StoragePlacePoly"."CoatingType" IS 'Код вида покрытия (уточнение)';
COMMENT ON COLUMN "work"."StoragePlacePoly"."AbutmentTypeList" IS 'Элементы сопряжения';
COMMENT ON COLUMN "work"."StoragePlacePoly"."MafsTypeList" IS 'МАФ';
COMMENT ON COLUMN "work"."StoragePlacePoly"."Unom" IS 'Данные UNOM';
COMMENT ON COLUMN "work"."StoragePlacePoly"."Unad" IS 'Данные UNAD';
COMMENT ON COLUMN "work"."StoragePlacePoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."StoragePlacePoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."StoragePlacePoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."StoragePlacePoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."StoragePlacePoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."StoragePlacePoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."StoragePlacePoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."StoragePlacePoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."StoragePlacePoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."StoragePlacePoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."StoragePlacePoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."StoragePlacePoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."StoragePlacePoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."StoragePlacePoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Некапитальные объекты для обеспечения производственной деятельности по содержанию и ремонту территорий
CREATE TABLE IF NOT EXISTS "work"."TechPlacePoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "BuildingsType" text NULL,
    "Material" text NULL,
    "Area" float8 NULL,
    "AbutmentTypeList" text NULL,
    "Unom" int8 NULL,
    "Unad" int8 NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "TechPlacePoly_Geom_idx" ON "work"."TechPlacePoly" USING gist ("Geometry");

ALTER TABLE "work"."TechPlacePoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."TechPlacePoly" TO mggt;
GRANT ALL ON TABLE "work"."TechPlacePoly" TO postgres;
GRANT ALL ON TABLE "work"."TechPlacePoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."TechPlacePoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."TechPlacePoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."TechPlacePoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."TechPlacePoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."TechPlacePoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."TechPlacePoly" IS 'Некапитальные объекты для обеспечения производственной деятельности по содержанию и ремонту территорий';
COMMENT ON COLUMN "work"."TechPlacePoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."TechPlacePoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."TechPlacePoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."TechPlacePoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."TechPlacePoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."TechPlacePoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."TechPlacePoly"."BuildingsType" IS 'Код назначения';
COMMENT ON COLUMN "work"."TechPlacePoly"."Material" IS 'Код материала';
COMMENT ON COLUMN "work"."TechPlacePoly"."Area" IS 'Площадь кв.м';
COMMENT ON COLUMN "work"."TechPlacePoly"."AbutmentTypeList" IS 'Элементы сопряжения';
COMMENT ON COLUMN "work"."TechPlacePoly"."Unom" IS 'Данные UNOM';
COMMENT ON COLUMN "work"."TechPlacePoly"."Unad" IS 'Данные UNAD';
COMMENT ON COLUMN "work"."TechPlacePoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."TechPlacePoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."TechPlacePoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."TechPlacePoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."TechPlacePoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."TechPlacePoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."TechPlacePoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."TechPlacePoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."TechPlacePoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."TechPlacePoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."TechPlacePoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."TechPlacePoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."TechPlacePoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."TechPlacePoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Светофорные объекты
CREATE TABLE IF NOT EXISTS "work"."TrafficLightPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "EquipmentType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "Endwise" float8 NULL,
    "MountingMode" text NULL,
    "TraffLightCar" int8 NULL,
    "TraffLightMen" int8 NULL,
    "Section" int8 NULL,
    "Placement" text NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "TrafficLightPoint_Geom_idx" ON "work"."TrafficLightPoint" USING gist ("Geometry");

ALTER TABLE "work"."TrafficLightPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."TrafficLightPoint" TO mggt;
GRANT ALL ON TABLE "work"."TrafficLightPoint" TO postgres;
GRANT ALL ON TABLE "work"."TrafficLightPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."TrafficLightPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."TrafficLightPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."TrafficLightPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."TrafficLightPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."TrafficLightPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."TrafficLightPoint" IS 'Светофорные объекты';
COMMENT ON COLUMN "work"."TrafficLightPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."TrafficLightPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."TrafficLightPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."TrafficLightPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."TrafficLightPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."TrafficLightPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."TrafficLightPoint"."EquipmentType" IS 'Код типа светофора';
COMMENT ON COLUMN "work"."TrafficLightPoint"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."TrafficLightPoint"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."TrafficLightPoint"."Endwise" IS 'По оси, м';
COMMENT ON COLUMN "work"."TrafficLightPoint"."MountingMode" IS 'Код типа установки';
COMMENT ON COLUMN "work"."TrafficLightPoint"."TraffLightCar" IS 'Состав оборудования. Светофор транспортный, шт.';
COMMENT ON COLUMN "work"."TrafficLightPoint"."TraffLightMen" IS 'Состав оборудования. Светофор пешеходный, шт.';
COMMENT ON COLUMN "work"."TrafficLightPoint"."Section" IS 'Состав оборудования. Секция поворотная';
COMMENT ON COLUMN "work"."TrafficLightPoint"."Placement" IS 'Код места размещения';
COMMENT ON COLUMN "work"."TrafficLightPoint"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."TrafficLightPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."TrafficLightPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."TrafficLightPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."TrafficLightPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."TrafficLightPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."TrafficLightPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."TrafficLightPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."TrafficLightPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."TrafficLightPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."TrafficLightPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."TrafficLightPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."TrafficLightPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Трамвайные пути
CREATE TABLE IF NOT EXISTS "work"."TramRailsPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "NetElementType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "Quantity" int8 NULL,
    "CoatingType" text NULL,
    "CoatingGroup" text NULL,
    "RoadCoatingType" text NULL,
    "RoadCoatingGroup" text NULL,
    "Distance" float8 NULL,
    "Area" float8 NULL,
    "SuspHeight" float8 NULL,
    -- Удалено в новой версии
    -- "CoatingTracksArea" float8 NULL,
    -- "CoatingBetweenRoadArea" float8 NULL,
    "Description" text NULL,
    "Detached" bool NULL,
    "IsIsolated" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL,
    "AxisGeometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "TramRailsPoly_Geom_idx" ON "work"."TramRailsPoly" USING gist ("Geometry");
CREATE INDEX IF NOT EXISTS "TramRailsPoly_AxisGeom_idx" ON "work"."TramRailsPoly" USING gist ("AxisGeometry");

ALTER TABLE "work"."TramRailsPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."TramRailsPoly" TO mggt;
GRANT ALL ON TABLE "work"."TramRailsPoly" TO postgres;
GRANT ALL ON TABLE "work"."TramRailsPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."TramRailsPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."TramRailsPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."TramRailsPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."TramRailsPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."TramRailsPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."TramRailsPoly" IS 'Трамвайные пути';
COMMENT ON COLUMN "work"."TramRailsPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."TramRailsPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."TramRailsPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."TramRailsPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."TramRailsPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."TramRailsPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."TramRailsPoly"."NetElementType" IS 'Код типа путей';
COMMENT ON COLUMN "work"."TramRailsPoly"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."TramRailsPoly"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."TramRailsPoly"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."TramRailsPoly"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."TramRailsPoly"."Quantity" IS 'Количество путей';
COMMENT ON COLUMN "work"."TramRailsPoly"."CoatingType" IS 'Код наименования вида покрытия (Вид покрытия на путях, уточнение)';
COMMENT ON COLUMN "work"."TramRailsPoly"."CoatingGroup" IS 'Код группы покрытия (Вид покрытия на путях)';
COMMENT ON COLUMN "work"."TramRailsPoly"."RoadCoatingType" IS 'Код наименования вида покрытия (Вид покрытия на сопряжении с проезжей частью, уточнение)';
COMMENT ON COLUMN "work"."TramRailsPoly"."RoadCoatingGroup" IS 'Код группы покрытия (Вид покрытия на сопряжении с проезжей частью)';
COMMENT ON COLUMN "work"."TramRailsPoly"."Distance" IS 'Длина путей, п.м.';
COMMENT ON COLUMN "work"."TramRailsPoly"."Area" IS 'Площадь, кв. м.';
COMMENT ON COLUMN "work"."TramRailsPoly"."SuspHeight" IS 'Высота подвески над проезжей частью, м';
-- Удалено в новой версии
-- COMMENT ON COLUMN "work"."TramRailsPoly"."CoatingTracksArea" IS 'Площадь по типу покрытия на путях, кв. м.';
-- COMMENT ON COLUMN "work"."TramRailsPoly"."CoatingBetweenRoadArea" IS 'Площадь по типу покрытия на сопряжении с ПЧ, кв. м.';
COMMENT ON COLUMN "work"."TramRailsPoly"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."TramRailsPoly"."Detached" IS 'Обособленные';
COMMENT ON COLUMN "work"."TramRailsPoly"."IsIsolated" IS 'В одном уровне';
COMMENT ON COLUMN "work"."TramRailsPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."TramRailsPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."TramRailsPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."TramRailsPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."TramRailsPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."TramRailsPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."TramRailsPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."TramRailsPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."TramRailsPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."TramRailsPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."TramRailsPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."TramRailsPoly"."Geometry" IS 'Геометрия объекта';
COMMENT ON COLUMN "work"."TramRailsPoly"."AxisGeometry" IS 'Геометрия осевой линии объекта';


-- Создаём Деревья и кустарники (Линия)
CREATE TABLE IF NOT EXISTS "work"."TreesShrubsLine"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "PlantationType" text NULL,
    "PlantType" text NULL,
    "LifeFormType" text NULL,
    "Age" float8 NULL,
    "Diameter" float8 NULL,
    "GreenNum" int8 NULL,
    "Height" float8 NULL,
    "SectionNum" int8 NULL,
    "Quantity" int8 NULL,
    "Area" float8 NULL,
    "Distance" float8 NULL,
    "BioGgroupNum" int8 NULL,
    "MillionTrees" bool NULL,
    "StateGardening" text NULL,
    "DetailedStateGardening" text NULL,
    "CharacteristicStateGardening" text NULL,
    "PlantServiceRecomendations" text NULL,
    "ValuablePlants" text NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "TreesShrubsLine_Geom_idx" ON "work"."TreesShrubsLine" USING gist ("Geometry");

ALTER TABLE "work"."TreesShrubsLine" OWNER to postgres;
GRANT ALL ON TABLE "work"."TreesShrubsLine" TO mggt;
GRANT ALL ON TABLE "work"."TreesShrubsLine" TO postgres;
GRANT ALL ON TABLE "work"."TreesShrubsLine" TO mggt_editor;
GRANT SELECT ON TABLE "work"."TreesShrubsLine" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."TreesShrubsLine_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."TreesShrubsLine_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."TreesShrubsLine_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."TreesShrubsLine_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."TreesShrubsLine" IS 'Деревья и кустарники (Линия)';
COMMENT ON COLUMN "work"."TreesShrubsLine".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."TreesShrubsLine"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."TreesShrubsLine"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."TreesShrubsLine"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."TreesShrubsLine"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."TreesShrubsLine"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."TreesShrubsLine"."PlantationType" IS 'Код типа насаждения';
COMMENT ON COLUMN "work"."TreesShrubsLine"."PlantType" IS 'Код вида растения';
COMMENT ON COLUMN "work"."TreesShrubsLine"."LifeFormType" IS 'Код жизненной формы';
COMMENT ON COLUMN "work"."TreesShrubsLine"."Age" IS 'Возраст';
COMMENT ON COLUMN "work"."TreesShrubsLine"."Diameter" IS 'Диаметр на высоте 1,3 м.';
COMMENT ON COLUMN "work"."TreesShrubsLine"."GreenNum" IS 'Номер растения';
COMMENT ON COLUMN "work"."TreesShrubsLine"."Height" IS 'Высота';
COMMENT ON COLUMN "work"."TreesShrubsLine"."SectionNum" IS 'Номер участка';
COMMENT ON COLUMN "work"."TreesShrubsLine"."Quantity" IS 'Количество, шт.';
COMMENT ON COLUMN "work"."TreesShrubsLine"."Area" IS 'Площадь кв.м';
COMMENT ON COLUMN "work"."TreesShrubsLine"."Distance" IS 'Протяженность, п.м';
COMMENT ON COLUMN "work"."TreesShrubsLine"."BioGgroupNum" IS 'Номер биогруппы';
COMMENT ON COLUMN "work"."TreesShrubsLine"."MillionTrees" IS 'Акция «Миллион деревьев»';
COMMENT ON COLUMN "work"."TreesShrubsLine"."StateGardening" IS 'Код состояния';
COMMENT ON COLUMN "work"."TreesShrubsLine"."DetailedStateGardening" IS 'Код уточнения состояния';
COMMENT ON COLUMN "work"."TreesShrubsLine"."CharacteristicStateGardening" IS 'Код характеристики состояния';
COMMENT ON COLUMN "work"."TreesShrubsLine"."PlantServiceRecomendations" IS 'Код рекомендации по уходу';
COMMENT ON COLUMN "work"."TreesShrubsLine"."ValuablePlants" IS 'Код признака «Особо ценные»';
COMMENT ON COLUMN "work"."TreesShrubsLine"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."TreesShrubsLine"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."TreesShrubsLine"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."TreesShrubsLine"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsLine"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsLine"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsLine"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsLine"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsLine"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."TreesShrubsLine"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."TreesShrubsLine"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."TreesShrubsLine"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."TreesShrubsLine"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."TreesShrubsLine"."Geometry" IS 'Геометрия объекта';


-- Создаём Деревья и кустарники (Точка)
CREATE TABLE IF NOT EXISTS "work"."TreesShrubsPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "PlantationType" text NULL,
    "PlantType" text NULL,
    "LifeFormType" text NULL,
    "Age" float8 NULL,
    "Diameter" float8 NULL,
    "GreenNum" int8 NULL,
    "Height" float8 NULL,
    "SectionNum" int8 NULL,
    "Quantity" int8 NULL,
    "Area" float8 NULL,
    "Distance" float8 NULL,
    "BioGgroupNum" int8 NULL,
    "MillionTrees" bool NULL,
    "StateGardening" text NULL,
    "DetailedStateGardening" text NULL,
    "CharacteristicStateGardening" text NULL,
    "PlantServiceRecomendations" text NULL,
    "ValuablePlants" text NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "TreesShrubsPoint_Geom_idx" ON "work"."TreesShrubsPoint" USING gist ("Geometry");

ALTER TABLE "work"."TreesShrubsPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."TreesShrubsPoint" TO mggt;
GRANT ALL ON TABLE "work"."TreesShrubsPoint" TO postgres;
GRANT ALL ON TABLE "work"."TreesShrubsPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."TreesShrubsPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."TreesShrubsPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."TreesShrubsPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."TreesShrubsPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."TreesShrubsPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."TreesShrubsPoint" IS 'Деревья и кустарники (Точка)';
COMMENT ON COLUMN "work"."TreesShrubsPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."PlantationType" IS 'Код типа насаждения';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."PlantType" IS 'Код вида растения';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."LifeFormType" IS 'Код жизненной формы';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."Age" IS 'Возраст';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."Diameter" IS 'Диаметр на высоте 1,3 м.';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."GreenNum" IS 'Номер растения';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."Height" IS 'Высота';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."SectionNum" IS 'Номер участка';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."Quantity" IS 'Количество, шт.';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."Area" IS 'Площадь кв.м';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."Distance" IS 'Протяженность, п.м';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."BioGgroupNum" IS 'Номер биогруппы';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."MillionTrees" IS 'Акция «Миллион деревьев»';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."StateGardening" IS 'Код состояния';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."DetailedStateGardening" IS 'Код уточнения состояния';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."CharacteristicStateGardening" IS 'Код характеристики состояния';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."PlantServiceRecomendations" IS 'Код рекомендации по уходу';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."ValuablePlants" IS 'Код признака «Особо ценные»';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."TreesShrubsPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Деревья и кустарники (Полигон)
CREATE TABLE IF NOT EXISTS "work"."TreesShrubsPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "PlantationType" text NULL,
    "PlantType" text NULL,
    "LifeFormType" text NULL,
    "Age" float8 NULL,
    "Diameter" float8 NULL,
    "GreenNum" int8 NULL,
    "Height" float8 NULL,
    "SectionNum" int8 NULL,
    "Quantity" int8 NULL,
    "Area" float8 NULL,
    "Distance" float8 NULL,
    "BioGgroupNum" int8 NULL,
    "MillionTrees" bool NULL,
    "StateGardening" text NULL,
    "DetailedStateGardening" text NULL,
    "CharacteristicStateGardening" text NULL,
    "PlantServiceRecomendations" text NULL,
    "ValuablePlants" text NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "TreesShrubsPoly_Geom_idx" ON "work"."TreesShrubsPoly" USING gist ("Geometry");

ALTER TABLE "work"."TreesShrubsPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."TreesShrubsPoly" TO mggt;
GRANT ALL ON TABLE "work"."TreesShrubsPoly" TO postgres;
GRANT ALL ON TABLE "work"."TreesShrubsPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."TreesShrubsPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."TreesShrubsPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."TreesShrubsPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."TreesShrubsPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."TreesShrubsPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."TreesShrubsPoly" IS 'Деревья и кустарники (Полигон)';
COMMENT ON COLUMN "work"."TreesShrubsPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."PlantationType" IS 'Код типа насаждения';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."PlantType" IS 'Код вида растения';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."LifeFormType" IS 'Код жизненной формы';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."Age" IS 'Возраст';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."Diameter" IS 'Диаметр на высоте 1,3 м.';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."GreenNum" IS 'Номер растения';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."Height" IS 'Высота';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."SectionNum" IS 'Номер участка';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."Quantity" IS 'Количество, шт.';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."Area" IS 'Площадь кв.м';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."Distance" IS 'Протяженность, п.м';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."BioGgroupNum" IS 'Номер биогруппы';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."MillionTrees" IS 'Акция «Миллион деревьев»';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."StateGardening" IS 'Код состояния';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."DetailedStateGardening" IS 'Код уточнения состояния';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."CharacteristicStateGardening" IS 'Код характеристики состояния';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."PlantServiceRecomendations" IS 'Код рекомендации по уходу';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."ValuablePlants" IS 'Код признака «Особо ценные»';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."TreesShrubsPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Трамвайные и троллейбусные контактные сети
CREATE TABLE IF NOT EXISTS "work"."TrolleybusContactNetworkLine"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "NetElementType" text NULL,
    "OdhSide" text NULL,
    "OdhAxis" text NULL,
    "BordBegin" float8 NULL,
    "BordEnd" float8 NULL,
    "Distance" float8 NULL,
    "Quantity" int8 NULL,
    "Description" text NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "TrolleybusContactNetworkLine_Geom_idx" ON "work"."TrolleybusContactNetworkLine" USING gist ("Geometry");

ALTER TABLE "work"."TrolleybusContactNetworkLine" OWNER to postgres;
GRANT ALL ON TABLE "work"."TrolleybusContactNetworkLine" TO mggt;
GRANT ALL ON TABLE "work"."TrolleybusContactNetworkLine" TO postgres;
GRANT ALL ON TABLE "work"."TrolleybusContactNetworkLine" TO mggt_editor;
GRANT SELECT ON TABLE "work"."TrolleybusContactNetworkLine" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."TrolleybusContactNetworkLine_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."TrolleybusContactNetworkLine_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."TrolleybusContactNetworkLine_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."TrolleybusContactNetworkLine_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."TrolleybusContactNetworkLine" IS 'Трамвайные и троллейбусные контактные сети';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."NetElementType" IS 'Код типа контактных сетей';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."OdhSide" IS 'Код стороны';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."OdhAxis" IS 'Ось';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."BordBegin" IS 'Начало, м';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."BordEnd" IS 'Конец, м';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."Distance" IS 'Длина контактных сетей, п.м.';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."Quantity" IS 'Количество контактных сетей, шт.';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."Description" IS 'Примечание';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."TrolleybusContactNetworkLine"."Geometry" IS 'Геометрия объекта';


-- Создаём Элементы вертикального озеленения
CREATE TABLE IF NOT EXISTS "work"."VerticalLandscapingPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "VerticalLandscapingType" text NULL,
    "VerticalLandscapingRefType" text NULL,
    "VerticalLandscapingClassType" text NULL,
    "PlacesQuantity" int8 NULL,
    "PlacesArea" float8 NULL,
    "Unit" text NULL,
    "Material" text NULL,
    "Quantity" float8 NULL,
    "ZoneOghId" text NULL,
    "IdRfid" text NULL,
    "InstallationDate" timestamp NULL,
    "Lifetime" timestamp NULL,
    "GuaranteePeriod" timestamp NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPoint, 980077) NULL);

CREATE INDEX IF NOT EXISTS "VerticalLandscapingPoint_Geom_idx" ON "work"."VerticalLandscapingPoint" USING gist ("Geometry");

ALTER TABLE "work"."VerticalLandscapingPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."VerticalLandscapingPoint" TO mggt;
GRANT ALL ON TABLE "work"."VerticalLandscapingPoint" TO postgres;
GRANT ALL ON TABLE "work"."VerticalLandscapingPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."VerticalLandscapingPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."VerticalLandscapingPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."VerticalLandscapingPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."VerticalLandscapingPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."VerticalLandscapingPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."VerticalLandscapingPoint" IS 'Элементы вертикального озеленения';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."VerticalLandscapingType" IS 'Код вида (наименование)';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."VerticalLandscapingRefType" IS 'Код типа (наименование)';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."VerticalLandscapingClassType" IS 'Код детализации (наименование)';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."PlacesQuantity" IS 'Количество посадочных мест';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."PlacesArea" IS 'Площадь посадочных мест';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."Unit" IS 'Код измерения (наименование)';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."Material" IS 'Код материала (наименование)';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."Quantity" IS 'Количество, шт.';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."ZoneOghId" IS 'Принадлежность к зоне';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."IdRfid" IS 'Id RFID метки';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."InstallationDate" IS 'Дата установки';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."Lifetime" IS 'Срок эксплуатации';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."GuaranteePeriod" IS 'Гарантийный срок';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."NoCalc" IS 'Не учитывать';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."IsDiffHeightMark" IS 'Разновысотные отметки';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."ParentStartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."ParentEndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."Geometry" IS 'Геометрия объекта';


-- Создаём Водные сооружения
CREATE TABLE IF NOT EXISTS "work"."WaterBuildingPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "WaterType" text NULL,
    "Area" float8 NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "WaterBuildingPoly_Geom_idx" ON "work"."WaterBuildingPoly" USING gist ("Geometry");

ALTER TABLE "work"."WaterBuildingPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."WaterBuildingPoly" TO mggt;
GRANT ALL ON TABLE "work"."WaterBuildingPoly" TO postgres;
GRANT ALL ON TABLE "work"."WaterBuildingPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."WaterBuildingPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."WaterBuildingPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."WaterBuildingPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."WaterBuildingPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."WaterBuildingPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."WaterBuildingPoly" IS 'Водные сооружения';
COMMENT ON COLUMN "work"."WaterBuildingPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."WaterType" IS 'Код назначения';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."Area" IS 'Площадь, кв.м.';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."WaterBuildingPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём Дворовая территория
CREATE TABLE IF NOT EXISTS "work"."YardPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "Name" text NULL,
    "OwnerLegalPersonId" int8 NULL,
    "OwnerLegalPersonVersionId" int8 NULL,
    "OwnerStartDate" timestamp NULL,
    "OwnerEndDate" timestamp NULL,
    "DepartmentLegalPersonId" int8 NULL,
    "DepartmentLegalPersonVersionId" int8 NULL,
    "DepartmentStartDate" timestamp NULL,
    "DepartmentEndDate" timestamp NULL,
    "CustomerLegalPersonId" int8 NULL,
    "CustomerLegalPersonVersionId" int8 NULL,
    "CustomerStartDate" timestamp NULL,
    "CustomertEndDate" timestamp NULL,
    "ImprovementCategory" text NULL,
    "ImprovementObjectCategory" text NULL,
    "Unom" int8 NULL,
    "Unad" int8 NULL,
    "PassportDraftOrg" text NULL,
    "PassportDate" timestamp NULL,
    "DateSurvey" timestamp NULL,
    "DateSurveyGreenZones" timestamp NULL,
    "TotalArea" float8 NULL,
    "TotalCleanArea" float8 NULL,
    "ManualCleanArea" float8 NULL,
    "AutoCleanArea" float8 NULL,
    "TotalCoverCleanArea" float8 NULL,
    "AsphaltCleanArea" float8 NULL,
    "SlabCleanArea" float8 NULL,
    "SoilCleanArea" float8 NULL,
    "RubberCleanArea" float8 NULL,
    "SandCleanArea" float8 NULL,
    "GraniteCleanArea" float8 NULL,
    "GrassCleanArea" float8 NULL,
    "PlasticCleanArea" float8 NULL,
    "GrassPaverCleanArea" float8 NULL,
    "TotalLawnArea" float8 NULL,
    "YardLawnAreaWithout" float8 NULL,
    "UsialLawnArea" float8 NULL,
    "ParterreLawnArea" float8 NULL,
    "LawnGridArea" float8 NULL,
    "LawnLawnArea" float8 NULL,
    "SlopeLawnArea" float8 NULL,
    "LawnOtherArea" float8 NULL,
    "CoverImproveAutoCleanArea" float8 NULL,
    "SnowCleanArea" float8 NULL,
    "ReservoirArea" float8 NULL,
    "RepairsInfoList" text NULL,
    "RepairsInfoListPlan" text NULL,
    "FileList" text NULL,
    "Tree" text NULL,
    "GreeningAddition" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "CreateType" text NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Okrug" text NULL,
    "District" text NULL,
	"PassBrId" int8 NULL,
	"Landscaping" text NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "YardPoly_Geom_idx" ON "work"."YardPoly" USING gist ("Geometry");

ALTER TABLE "work"."YardPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."YardPoly" TO mggt;
GRANT ALL ON TABLE "work"."YardPoly" TO postgres;
GRANT ALL ON TABLE "work"."YardPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."YardPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."YardPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."YardPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."YardPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."YardPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."YardPoly" IS 'Дворовая территория';
COMMENT ON COLUMN "work"."YardPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."YardPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."YardPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."YardPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."YardPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."YardPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."YardPoly"."Name" IS 'Наименование объекта';
COMMENT ON COLUMN "work"."YardPoly"."OwnerLegalPersonId" IS 'ID балансодержателя';
COMMENT ON COLUMN "work"."YardPoly"."OwnerLegalPersonVersionId" IS 'Версия балансодержателя';
COMMENT ON COLUMN "work"."YardPoly"."OwnerStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."YardPoly"."OwnerEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."YardPoly"."DepartmentLegalPersonId" IS 'ID ведомственного ОИВ';
COMMENT ON COLUMN "work"."YardPoly"."DepartmentLegalPersonVersionId" IS 'Версия ведомственного ОИВ';
COMMENT ON COLUMN "work"."YardPoly"."DepartmentStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."YardPoly"."DepartmentEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."YardPoly"."CustomerLegalPersonId" IS 'ID заказчика';
COMMENT ON COLUMN "work"."YardPoly"."CustomerLegalPersonVersionId" IS 'Версия заказчика';
COMMENT ON COLUMN "work"."YardPoly"."CustomerStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."YardPoly"."CustomertEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."YardPoly"."ImprovementCategory" IS 'Код категории благоустройства';
COMMENT ON COLUMN "work"."YardPoly"."ImprovementObjectCategory" IS 'Код категории озеленения';
COMMENT ON COLUMN "work"."YardPoly"."Unom" IS 'Данные UNOM';
COMMENT ON COLUMN "work"."YardPoly"."Unad" IS 'Данные UNAD';
COMMENT ON COLUMN "work"."YardPoly"."PassportDraftOrg" IS 'Исполнитель/Исполнители работ (по разработке, актуализации паспорта)';
COMMENT ON COLUMN "work"."YardPoly"."PassportDate" IS 'Дата составления';
COMMENT ON COLUMN "work"."YardPoly"."DateSurvey" IS 'Дата обследования территории';
COMMENT ON COLUMN "work"."YardPoly"."DateSurveyGreenZones" IS 'Дата обследования территории (дополнение сведений по ЗН)';
COMMENT ON COLUMN "work"."YardPoly"."TotalArea" IS 'Общая площадь объекта, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."TotalCleanArea" IS 'Общая уборочная площадь, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."ManualCleanArea" IS 'Площадь ручной уборки, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."AutoCleanArea" IS 'Площадь механизированной уборки, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."TotalCoverCleanArea" IS 'Общая уборочная площадь по покрытиям, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."AsphaltCleanArea" IS 'Асфальтобетонное, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."SlabCleanArea" IS 'Плиточное (Плитка или тактильная плитка), кв. м';
COMMENT ON COLUMN "work"."YardPoly"."SoilCleanArea" IS 'Грунтовое, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."RubberCleanArea" IS 'Мягкое из резиновой крошки, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."SandCleanArea" IS 'Мягкое из песка, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."GraniteCleanArea" IS 'Мягкое из гранитной высевки, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."GrassCleanArea" IS 'Мягкое из искусственной травы, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."PlasticCleanArea" IS 'Пластиковое, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."GrassPaverCleanArea" IS 'Газонная решетка (экопарковка), кв. м';
COMMENT ON COLUMN "work"."YardPoly"."TotalLawnArea" IS 'Общая площадь газонов, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."YardLawnAreaWithout" IS 'Площадь за вычетом насаждений кв.м';
COMMENT ON COLUMN "work"."YardPoly"."UsialLawnArea" IS 'Обыкновенный, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."ParterreLawnArea" IS 'Партерный, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."LawnGridArea" IS 'На ячеистом основании, экопарковки, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."LawnLawnArea" IS 'Луговой, разнотравный, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."SlopeLawnArea" IS 'На откосе, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."LawnOtherArea" IS 'Иного типа, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."CoverImproveAutoCleanArea" IS 'Территория уборки усовершенствованных покрытий, механизированная';
COMMENT ON COLUMN "work"."YardPoly"."SnowCleanArea" IS 'Площадь вывоза снега, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."ReservoirArea" IS 'Водоемы, кв. м';
COMMENT ON COLUMN "work"."YardPoly"."RepairsInfoList" IS 'Перечень ремонтных работ';
COMMENT ON COLUMN "work"."YardPoly"."RepairsInfoListPlan" IS 'Перечень проектных работ';
COMMENT ON COLUMN "work"."YardPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."YardPoly"."Tree" IS 'Перечень дочерних объектов';
COMMENT ON COLUMN "work"."YardPoly"."GreeningAddition" IS 'Признак «Требует дополнения по зеленым насаждениям»';
COMMENT ON COLUMN "work"."YardPoly"."IsDiffHeightMark" IS 'Признак «Разновысотный ОГХ»';
COMMENT ON COLUMN "work"."YardPoly"."CreateType" IS 'Тип создания';
COMMENT ON COLUMN "work"."YardPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."YardPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."YardPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."YardPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."YardPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."YardPoly"."Geometry" IS 'Геометрия объекта';
COMMENT ON COLUMN "work"."YardPoly"."Okrug" IS 'Округ';
COMMENT ON COLUMN "work"."YardPoly"."District" IS 'Район';
COMMENT ON COLUMN "work"."YardPoly"."Landscaping" IS 'Работы по благоустройству';
COMMENT ON COLUMN "work"."YardPoly"."PassBrId" IS 'Номер заявки на обследование';


-- Создаем слой вспомогательных линий
CREATE TABLE IF NOT EXISTS "work"."AuxilaryLines"(
    fid serial PRIMARY KEY NOT NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "AuxilaryLines_Geom_idx" ON "work"."AuxilaryLines" USING gist ("Geometry");

ALTER TABLE "work"."AuxilaryLines" OWNER to postgres;
GRANT ALL ON TABLE "work"."AuxilaryLines" TO mggt;
GRANT ALL ON TABLE "work"."AuxilaryLines" TO postgres;
GRANT ALL ON TABLE "work"."AuxilaryLines" TO mggt_editor;
GRANT SELECT ON TABLE "work"."AuxilaryLines" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."AuxilaryLines_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."AuxilaryLines_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."AuxilaryLines_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."AuxilaryLines_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."AuxilaryLines" IS 'Вспомогательные линии';
COMMENT ON COLUMN "work"."AuxilaryLines".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."AuxilaryLines"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."AuxilaryLines"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."AuxilaryLines"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."AuxilaryLines"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."AuxilaryLines"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."AuxilaryLines"."Geometry" IS 'Геометрия объекта';

-- В свзяи с тем, что таблица уже используется добавляем столбец с типом отдельно
ALTER TABLE "work"."AuxilaryLines" ADD COLUMN IF NOT EXISTS "AuxType" int2 DEFAULT 1 NOT NULL;
COMMENT ON COLUMN "work"."AuxilaryLines"."AuxType" IS 'Тип вспомогательной линии';

-- Создаем слой линий для переноса зеленых насаждений
CREATE TABLE IF NOT EXISTS "work"."TreeMergeLines"(
    fid serial PRIMARY KEY NOT NULL,
	"CellId" int NULL,
	"CellName" text NULL,
	"TreeId" int NULL,
	"Distance" float8 NULL,
	"Error" text NULL,
	"IsDiffHeightMark" bool NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(LineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "TreeMergeLines_Geom_idx" ON "work"."TreeMergeLines" USING gist ("Geometry");

ALTER TABLE "work"."TreeMergeLines" OWNER to postgres;
GRANT ALL ON TABLE "work"."TreeMergeLines" TO mggt;
GRANT ALL ON TABLE "work"."TreeMergeLines" TO postgres;
GRANT ALL ON TABLE "work"."TreeMergeLines" TO mggt_editor;
GRANT SELECT ON TABLE "work"."TreeMergeLines" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."TreeMergeLines_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."TreeMergeLines_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."TreeMergeLines_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."TreeMergeLines_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."TreeMergeLines" IS 'Вспомогательные линии';
COMMENT ON COLUMN "work"."TreeMergeLines".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."TreeMergeLines"."CellId" IS 'ID точки зеленого насаждения топографии';
COMMENT ON COLUMN "work"."TreeMergeLines"."CellName" IS 'Название CELL зеленого насаждения топографии';
COMMENT ON COLUMN "work"."TreeMergeLines"."TreeId" IS 'ID точки зеленого насаждения рабочего реестра';
COMMENT ON COLUMN "work"."TreeMergeLines"."Distance" IS 'Расстояние между точками';
COMMENT ON COLUMN "work"."TreeMergeLines"."Error" IS 'Текст ошибки';
COMMENT ON COLUMN "work"."TreeMergeLines"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."TreeMergeLines"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."TreeMergeLines"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."TreeMergeLines"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."TreeMergeLines"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."TreeMergeLines"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."TreeMergeLines"."Geometry" IS 'Геометрия объекта';


-- Создаем слой осевых линий ОДХ
CREATE TABLE IF NOT EXISTS "work"."AxialLines"(
    fid serial PRIMARY KEY NOT NULL,
	"LineType" int NOT NULL,
	"AxisName" text NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "AxialLines_Geom_idx" ON "work"."AxialLines" USING gist ("Geometry");

ALTER TABLE "work"."AxialLines" OWNER to postgres;
GRANT ALL ON TABLE "work"."AxialLines" TO mggt;
GRANT ALL ON TABLE "work"."AxialLines" TO postgres;
GRANT ALL ON TABLE "work"."AxialLines" TO mggt_editor;
GRANT SELECT ON TABLE "work"."AxialLines" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."AxialLines_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."AxialLines_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."AxialLines_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."AxialLines_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."AxialLines" IS 'Осевые линии ОДХ';
COMMENT ON COLUMN "work"."AxialLines".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."AxialLines"."LineType" IS 'Тип осевой линии';
COMMENT ON COLUMN "work"."AxialLines"."AxisName" IS 'Название оси';
COMMENT ON COLUMN "work"."AxialLines"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."AxialLines"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."AxialLines"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."AxialLines"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."AxialLines"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."AxialLines"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."AxialLines"."Geometry" IS 'Геометрия объекта';


-- Создаём слой полигонов для правок
CREATE TABLE IF NOT EXISTS "work"."CorrectionsPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "TaskGUID" uuid NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "CorrectionsPoly_Geom_idx" ON "work"."CorrectionsPoly" USING gist ("Geometry");

ALTER TABLE "work"."CorrectionsPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."CorrectionsPoly" TO mggt;
GRANT ALL ON TABLE "work"."CorrectionsPoly" TO postgres;
GRANT ALL ON TABLE "work"."CorrectionsPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."CorrectionsPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."CorrectionsPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."CorrectionsPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."CorrectionsPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."CorrectionsPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."CorrectionsPoly" IS 'Полигоны для правок';
COMMENT ON COLUMN "work"."CorrectionsPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."CorrectionsPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."CorrectionsPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."CorrectionsPoly"."Geometry" IS 'Геометрия объекта';


-- Создаём слой базовых полигонов
CREATE TABLE IF NOT EXISTS "work"."BasePoly"(
    fid serial PRIMARY KEY NOT NULL,
    "Info" text NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "ElementType" text NULL,
    "SetManually" bool NULL,
	"IsDiffHeightMark" bool NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL,
    "AxisGeometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "BasePoly_Geom_idx" ON "work"."BasePoly" USING gist ("Geometry");
CREATE INDEX IF NOT EXISTS "BasePoly_AxisGeom_idx" ON work."BasePoly" USING gist ("AxisGeometry");

ALTER TABLE "work"."BasePoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."BasePoly" TO mggt;
GRANT ALL ON TABLE "work"."BasePoly" TO postgres;
GRANT ALL ON TABLE "work"."BasePoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."BasePoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."BasePoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."BasePoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."BasePoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."BasePoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."BasePoly" IS 'Базовые полигоны для атрибутации';
COMMENT ON COLUMN "work"."BasePoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."BasePoly"."Info" IS 'Информация о полигоне';
COMMENT ON COLUMN "work"."BasePoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."BasePoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."BasePoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."BasePoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."BasePoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."BasePoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."BasePoly"."ElementType" IS 'Тип элемента базового полигона';
COMMENT ON COLUMN "work"."BasePoly"."SetManually" IS 'Признак того, что тип элемента задан вручную';
COMMENT ON COLUMN "work"."BasePoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."BasePoly"."Geometry" IS 'Геометрия объекта';
COMMENT ON COLUMN "work"."BasePoly"."AxisGeometry" IS 'Геометрия осевой линии объекта';

-- Создаём слой точек фотофиксации
CREATE TABLE IF NOT EXISTS "work"."PhotoFixPoint"(
    fid serial PRIMARY KEY NOT NULL,
    "PhotoName" text NULL,
	"TaskName" text NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(Point, 980077) NULL);

CREATE INDEX IF NOT EXISTS "PhotoFixPoint_Geom_idx" ON "work"."PhotoFixPoint" USING gist ("Geometry");

ALTER TABLE "work"."PhotoFixPoint" OWNER to postgres;
GRANT ALL ON TABLE "work"."PhotoFixPoint" TO mggt;
GRANT ALL ON TABLE "work"."PhotoFixPoint" TO postgres;
GRANT ALL ON TABLE "work"."PhotoFixPoint" TO mggt_editor;
GRANT SELECT ON TABLE "work"."PhotoFixPoint" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."PhotoFixPoint_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."PhotoFixPoint_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."PhotoFixPoint_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."PhotoFixPoint_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."PhotoFixPoint" IS 'Базовые полигоны для атрибутации';
COMMENT ON COLUMN "work"."PhotoFixPoint".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."PhotoFixPoint"."PhotoName" IS 'Название файла фото';
COMMENT ON COLUMN "work"."PhotoFixPoint"."TaskName" IS 'Название папки задачи, в которой расположено фото';
COMMENT ON COLUMN "work"."PhotoFixPoint"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."PhotoFixPoint"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."PhotoFixPoint"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."PhotoFixPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."PhotoFixPoint"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."PhotoFixPoint"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."PhotoFixPoint"."Geometry" IS 'Геометрия объекта';


---- Тут идут изменения в таблицах
ALTER TABLE "work"."OznPoly" ADD COLUMN IF NOT EXISTS "OznType" int8 NULL;
COMMENT ON COLUMN "work"."OznPoly"."OznType" IS 'Код типа ОО';

ALTER TABLE "work"."EngineerBuildingPoint" ALTER COLUMN "Quantity" TYPE float8 USING "Quantity"::float8;
ALTER TABLE "work"."EngineerBuildingPoly" ALTER COLUMN "Quantity" TYPE float8 USING "Quantity"::float8;

ALTER TABLE "work"."FencingPoint" ADD COLUMN IF NOT EXISTS "IsTitle" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."FencingPoint"."IsTitle" IS 'Включать в ТС (Титульном списке)';

ALTER TABLE "work"."FencingLine" ADD COLUMN IF NOT EXISTS "IsTitle" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."FencingLine"."IsTitle" IS 'Включать в ТС (Титульном списке)';

ALTER TABLE "work"."FencingPoly" ADD COLUMN IF NOT EXISTS "IsTitle" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."FencingPoly"."IsTitle" IS 'Включать в ТС (Титульном списке)';

UPDATE "work"."FencingPoint" SET "IsTitle" = FALSE;
UPDATE "work"."FencingLine" SET "IsTitle" = FALSE;
UPDATE "work"."FencingPoly" SET "IsTitle" = FALSE;

ALTER TABLE work."FencingPoly" ADD "AxisGeometry" public.geometry(multilinestring, 980077) NULL;
CREATE INDEX IF NOT EXISTS "FencingPoly_AxisGeom_idx" ON "work"."FencingPoly" USING gist ("AxisGeometry");

-- Добавляем поле "Без уборки" в опорные полигоны
ALTER TABLE "work"."BasePoly" ADD COLUMN IF NOT EXISTS "NoClean" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."BasePoly"."NoClean" IS 'Признак без уборки';
UPDATE "work"."BasePoly" SET "NoClean" = FALSE;

-- Добавляем поле "Порода растения МГГТ" в слои ЗН
ALTER TABLE "work"."TreesShrubsPoint" ADD COLUMN IF NOT EXISTS "WoodType" text DEFAULT NULL;
COMMENT ON COLUMN "work"."TreesShrubsPoint"."WoodType" IS 'Порода растения МГГТ';

ALTER TABLE "work"."TreesShrubsLine" ADD COLUMN IF NOT EXISTS "WoodType" text DEFAULT NULL;
COMMENT ON COLUMN "work"."TreesShrubsLine"."WoodType" IS 'Порода растения МГГТ';

ALTER TABLE "work"."TreesShrubsPoly" ADD COLUMN IF NOT EXISTS "WoodType" text DEFAULT NULL;
COMMENT ON COLUMN "work"."TreesShrubsPoly"."WoodType" IS 'Порода растения МГГТ';

DROP TABLE IF EXISTS "work"."ImprovementObjectPoly";
CREATE TABLE IF NOT EXISTS "work"."ImprovementObjectPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "Name" text NULL,
    "OwnerLegalPersonId" int8 NULL,
    "OwnerLegalPersonVersionId" int8 NULL,
    "OwnerStartDate" timestamp NULL,
    "OwnerEndDate" timestamp NULL,
    "DepartmentLegalPersonId" int8 NULL,
    "DepartmentLegalPersonVersionId" int8 NULL,
    "DepartmentStartDate" timestamp NULL,
    "DepartmentEndDate" timestamp NULL,
    "CustomerLegalPersonId" int8 NULL,
    "CustomerLegalPersonVersionId" int8 NULL,
    "CustomerStartDate" timestamp NULL,
    "CustomertEndDate" timestamp NULL,
    "ImprovementCategory" text NULL,
    "ImprovementObjectCategory" text NULL,
    "Okrug" text NULL,
    "District" text NULL,
    "PassportDraftOrg" text NULL,
    "PassportDate" timestamp NULL,
    "DateSurvey" timestamp NULL,
    "DateSurveyGreenZones" timestamp NULL,
    "TotalArea" float8 NULL,
    "TotalCleanArea" float8 NULL,
    "ManualCleanArea" float8 NULL,
    "AutoCleanArea" float8 NULL,
    "TotalCoverCleanArea" float8 NULL,
    "AsphaltCleanArea" float8 NULL,
    "SlabCleanArea" float8 NULL,
    "SoilCleanArea" float8 NULL,
    "RubberCleanArea" float8 NULL,
    "SandCleanArea" float8 NULL,
    "GraniteCleanArea" float8 NULL,
    "GrassCleanArea" float8 NULL,
    "PlasticCleanArea" float8 NULL,
    "GrassPaverCleanArea" float8 NULL,
    "TotalLawnArea" float8 NULL,
    "UsialLawnArea" float8 NULL,
    "ParterreLawnArea" float8 NULL,
    "LawnGridArea" float8 NULL,
    "LawnLawnArea" float8 NULL,
    "SlopeLawnArea" float8 NULL,
    "LawnOtherArea" float8 NULL,
    "CoverImproveAutoCleanArea" float8 NULL,
    "SnowCleanArea" float8 NULL,

    -- Нету в доке
    "SmmCleanArea" float8 NULL,
    "ReservoirArea" float8 NULL,
    "FileList" text NULL,

    "TinaoTerritory" bool NULL,
    "GreeningAddition" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "RepairsInfoList" text NULL,
    "RepairsInfoListPlan" text NULL,
    "Tree" text NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "ImprovementObjectPoly_Geom_idx" ON "work"."ImprovementObjectPoly" USING gist ("Geometry");

ALTER TABLE "work"."ImprovementObjectPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."ImprovementObjectPoly" TO mggt;
GRANT ALL ON TABLE "work"."ImprovementObjectPoly" TO postgres;
GRANT ALL ON TABLE "work"."ImprovementObjectPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."ImprovementObjectPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."ImprovementObjectPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."ImprovementObjectPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."ImprovementObjectPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."ImprovementObjectPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."ImprovementObjectPoly" IS 'Территории общего пользования';
COMMENT ON COLUMN "work"."ImprovementObjectPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."Name" IS 'Наименование объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."OwnerLegalPersonId" IS 'ID балансодержателя';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."OwnerLegalPersonVersionId" IS 'Версия балансодержателя';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."OwnerStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."OwnerEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."DepartmentLegalPersonId" IS 'ID ведомственного ОИВ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."DepartmentLegalPersonVersionId" IS 'Версия ведомственного ОИВ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."DepartmentStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."DepartmentEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CustomerLegalPersonId" IS 'ID заказчика';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CustomerLegalPersonVersionId" IS 'Версия заказчика';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CustomerStartDate" IS 'Действует с';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CustomertEndDate" IS 'Действует по';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ImprovementCategory" IS 'Категория благоустройства';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ImprovementObjectCategory" IS 'Категория озеленения';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."Okrug" IS 'Округ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."District" IS 'Район';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."PassportDraftOrg" IS 'Исполнитель/Исполнители работ (по разработке, актуализации паспорта)';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."PassportDate" IS 'Дата составления/согласования паспорта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."DateSurvey" IS 'Дата обследования территории';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."DateSurveyGreenZones" IS 'Дата обследования территории (дополнение сведений по ЗН)';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TotalArea" IS 'Общая площадь объекта, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TotalCleanArea" IS 'Общая уборочная площадь, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ManualCleanArea" IS 'Площадь ручной уборки, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."AutoCleanArea" IS 'Площадь механизированной уборки, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TotalCoverCleanArea" IS 'Общая уборочная площадь по покрытиям, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."AsphaltCleanArea" IS 'Асфальтобетонное, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."SlabCleanArea" IS 'Плиточное (Плитка или тактильная плитка), кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."SoilCleanArea" IS 'Грунтовое, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."RubberCleanArea" IS 'Мягкое из резиновой крошки, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."SandCleanArea" IS 'Мягкое из песка, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."GraniteCleanArea" IS 'Мягкое из гранитной высевки, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."GrassCleanArea" IS 'Мягкое из искусственной травы, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."PlasticCleanArea" IS 'Пластиковое, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."GrassPaverCleanArea" IS 'Газонная решетка (экопарковка), кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TotalLawnArea" IS 'Общая площадь газонов, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."UsialLawnArea" IS 'Обыкновенный, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ParterreLawnArea" IS 'Партерный, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."LawnGridArea" IS 'На ячеистом основании, экопарковки, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."LawnLawnArea" IS 'Луговой, разнотравный, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."SlopeLawnArea" IS 'На откосе, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."LawnOtherArea" IS 'Иного типа, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CoverImproveAutoCleanArea" IS 'Территория уборки усовершенствованных покрытий, механизированная';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."SnowCleanArea" IS 'Площадь вывоза снега, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."SmmCleanArea" IS '';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ReservoirArea" IS 'Водоемы, кв. м';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TinaoTerritory" IS 'Признак «Территория особого содержания ТиНАО»';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."GreeningAddition" IS 'Признак «Требует дополнения по зеленым насаждениям»';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."IsDiffHeightMark" IS 'Признак «Разновысотный ОГХ»';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."RepairsInfoList" IS 'Перечень ремонтных работ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."RepairsInfoListPlan" IS 'Перечень проектных работ';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."Tree" IS 'Перечень дочерних объектов';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."Geometry" IS 'Геометрия объекта';

ALTER TABLE "work"."PhotoFixPoint" ADD COLUMN IF NOT EXISTS "Direction" float8 NULL;
COMMENT ON COLUMN "work"."PhotoFixPoint"."Direction" IS 'Угол по азимуту, в направление которого производилась фотосъёмка (достоверность зависит от данных GPS)';

ALTER TABLE "work"."RoadSignsLine" ADD COLUMN IF NOT EXISTS "SignText" text NULL;
COMMENT ON COLUMN "work"."RoadSignsLine"."SignText" IS 'Текст на знаке';

-- Создаём катки в ворке
CREATE TABLE IF NOT EXISTS "work"."IceRinkPoly"(
    fid serial PRIMARY KEY NOT NULL,
    "OghObjectType" text NULL,
    "ObjectId" int8 NULL,
    "RootId" int8 NULL,
    "StartDate" timestamp NULL,
    "EndDate" timestamp NULL,
    "IceRinkType" text NULL,
    "CoatingType" text NULL,
    "CoatingGroup" text NULL,
    "TotalArea" float8 NULL,
    "ManualCleanArea" float8 NULL,
    "AutoCleanArea" float8 NULL,
    "Property" text NULL,
    "AbutmentTypeList" text NULL,
    "FileList" text NULL,
    "NoCalc" bool NULL,
    "IsDiffHeightMark" bool NULL,
    "GroupId" int8 NULL,
    "ParentOghObjectType" text NULL,
    "ParentObjectId" int8 NULL,
    "ParentRootId" int8 NULL,
    "ParentStartDate" timestamp NULL,
    "ParentEndDate" timestamp NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "IsSmmCleaning" bool NULL,
    "Geometry" geometry(MultiPolygon, 980077) NULL);

CREATE INDEX IF NOT EXISTS "IceRinkPoly_Geom_idx" ON "work"."IceRinkPoly" USING gist ("Geometry");

ALTER TABLE "work"."IceRinkPoly" OWNER to postgres;
GRANT ALL ON TABLE "work"."IceRinkPoly" TO mggt;
GRANT ALL ON TABLE "work"."IceRinkPoly" TO postgres;
GRANT ALL ON TABLE "work"."IceRinkPoly" TO mggt_editor;
GRANT SELECT ON TABLE "work"."IceRinkPoly" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."IceRinkPoly_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."IceRinkPoly_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."IceRinkPoly_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."IceRinkPoly_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."IceRinkPoly" IS 'Плоскостные сооружения';
COMMENT ON COLUMN "work"."IceRinkPoly".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."IceRinkPoly"."OghObjectType" IS 'Код типа ОГХ';
COMMENT ON COLUMN "work"."IceRinkPoly"."ObjectId" IS 'Идентификатор версии ОГХ';
COMMENT ON COLUMN "work"."IceRinkPoly"."RootId" IS 'Идентификатор ОГХ';
COMMENT ON COLUMN "work"."IceRinkPoly"."StartDate" IS 'Дата начала действия';
COMMENT ON COLUMN "work"."IceRinkPoly"."EndDate" IS 'Дата окончания действия';
COMMENT ON COLUMN "work"."IceRinkPoly"."IceRinkType" IS 'Код типа катка';
COMMENT ON COLUMN "work"."IceRinkPoly"."CoatingType" IS 'Код наименования вида покрытия (Вид покрытия, уточнение)';
COMMENT ON COLUMN "work"."IceRinkPoly"."CoatingGroup" IS 'Код группы покрытия (Вид покрытия)';
COMMENT ON COLUMN "work"."IceRinkPoly"."TotalArea" IS 'Площадь кв.м';
COMMENT ON COLUMN "work"."IceRinkPoly"."ManualCleanArea" IS 'Площадь уборки ручн., кв.м';
COMMENT ON COLUMN "work"."IceRinkPoly"."AutoCleanArea" IS 'Площадь уборки мех., кв.м';
COMMENT ON COLUMN "work"."IceRinkPoly"."Property" IS 'Характеристика';
COMMENT ON COLUMN "work"."IceRinkPoly"."AbutmentTypeList" IS 'Элементы сопряжения';
COMMENT ON COLUMN "work"."IceRinkPoly"."FileList" IS 'Документы';
COMMENT ON COLUMN "work"."IceRinkPoly"."NoCalc" IS 'Признак «Не учитывать»';
COMMENT ON COLUMN "work"."IceRinkPoly"."IsDiffHeightMark" IS 'Признак «Разновысотные отметки»';
COMMENT ON COLUMN "work"."IceRinkPoly"."GroupId" IS 'Является частью составного объекта';
COMMENT ON COLUMN "work"."IceRinkPoly"."ParentOghObjectType" IS 'Код типа родительского объекта';
COMMENT ON COLUMN "work"."IceRinkPoly"."ParentObjectId" IS 'Идентификатор версии родительского объекта';
COMMENT ON COLUMN "work"."IceRinkPoly"."ParentRootId" IS 'Идентификатор родительского объекта';
COMMENT ON COLUMN "work"."IceRinkPoly"."ParentStartDate" IS 'Дата начала действия родительского объекта';
COMMENT ON COLUMN "work"."IceRinkPoly"."ParentEndDate" IS 'Дата окончания действия родительского объекта';
COMMENT ON COLUMN "work"."IceRinkPoly"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."IceRinkPoly"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."IceRinkPoly"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."IceRinkPoly"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."IceRinkPoly"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."IceRinkPoly"."IsSmmCleaning" IS 'Признак «Уборка с применением СММ»';
COMMENT ON COLUMN "work"."IceRinkPoly"."Geometry" IS 'Геометрия объекта';

-- Добавляем в рабочий слой знаков поле "На желтом фоне"
ALTER TABLE "work"."RoadSignsLine" ADD COLUMN IF NOT EXISTS "OnYellowBack" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."RoadSignsLine"."OnYellowBack" IS 'Знак на желтом фоне';

ALTER TABLE "work"."ImprovementObjectPoly" ADD COLUMN IF NOT EXISTS "CreateType" text NULL;
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."CreateType" IS 'Тип создания';

ALTER TABLE "work"."ImprovementObjectPoly" ADD COLUMN IF NOT EXISTS "Landscaping" text NULL;
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."Landscaping" IS 'Работы по благоустройству';

ALTER TABLE "work"."AbutmentLine" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."AuxilaryLines" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."AxialLines" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."BasePoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."BoardStoneLine" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."BuildingPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."CarriagewayPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."ContainerPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."ContainerPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."CorrectionsPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."DtsPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."EngineerBuildingPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."EngineerBuildingPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."FencingLine" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."FencingPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."FencingPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."FlowersGardenPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."FunctionalityLine" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."FunctionalityPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."FunctionalityPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."IceRinkPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."ImprovementObjectPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."LamppostsPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."LawnPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."LittleFormLine" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."LittleFormPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."LittleFormPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."MafPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."MafPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."ManholesPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."MarginPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."OdhPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."OtherEnginConstructPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."OtherEnginConstructPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."OtherFlatBuildingPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."OtherOksPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."OtherTechPlacePoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."OznPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."PhotoFixPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."PlanarStructurePoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."PpiLine" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."PpiPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."PpiPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."RedBookPlantPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."ReliefLine" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."ReliefPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."ReliefPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."RoadSignsLine" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."SidewalksPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."SpaPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."StopsPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."StoragePlacePoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."task" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."TechPlacePoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."TrafficLightPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."TramRailsPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."TreeMergeLines" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."TreesShrubsLine" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."TreesShrubsPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."TreesShrubsPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."TrolleybusContactNetworkLine" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."VerticalLandscapingPoint" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."WaterBuildingPoly" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."WorkArea" ALTER COLUMN "fid" TYPE BIGINT;
ALTER TABLE "work"."YardPoly" ALTER COLUMN "fid" TYPE BIGINT;

ALTER TABLE "work"."OtherEnginConstructPoly" ADD COLUMN IF NOT EXISTS "IsHided" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."IsHided" IS 'Признак скрытия объекта для отображения';

-- МАФ и элементы благоустройства (Точка)
ALTER TABLE "work"."LittleFormPoint" ADD COLUMN IF NOT EXISTS "Svg" text NULL;
COMMENT ON COLUMN "work"."LittleFormPoint"."Svg" IS 'Путь к SVG иконкам';

ALTER TABLE "work"."LittleFormPoint" ADD COLUMN IF NOT EXISTS "Svg_VAPoint" text NULL;
COMMENT ON COLUMN "work"."LittleFormPoint"."Svg_VAPoint" IS 'Вертикальная точка привязки SVG';

ALTER TABLE "work"."LittleFormPoint" ADD COLUMN IF NOT EXISTS "Svg_HAPoint" text NULL;
COMMENT ON COLUMN "work"."LittleFormPoint"."Svg_HAPoint" IS 'Горизонтальная точка привязки SVG';

-- Системы функционального обеспечения (Точка)
ALTER TABLE "work"."FunctionalityPoint" ADD COLUMN IF NOT EXISTS "Svg" text NULL;
COMMENT ON COLUMN "work"."FunctionalityPoint"."Svg" IS 'Путь к SVG иконкам';

ALTER TABLE "work"."FunctionalityPoint" ADD COLUMN IF NOT EXISTS "Svg_VAPoint" text NULL;
COMMENT ON COLUMN "work"."FunctionalityPoint"."Svg_VAPoint" IS 'Вертикальная точка привязки SVG';

ALTER TABLE "work"."FunctionalityPoint" ADD COLUMN IF NOT EXISTS "Svg_HAPoint" text NULL;
COMMENT ON COLUMN "work"."FunctionalityPoint"."Svg_HAPoint" IS 'Горизонтальная точка привязки SVG';

-- Элементы вертикального озеленения
ALTER TABLE "work"."VerticalLandscapingPoint" ADD COLUMN IF NOT EXISTS "Svg" text NULL;
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."Svg" IS 'Путь к SVG иконкам';

ALTER TABLE "work"."VerticalLandscapingPoint" ADD COLUMN IF NOT EXISTS "Svg_VAPoint" text NULL;
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."Svg_VAPoint" IS 'Вертикальная точка привязки SVG';

ALTER TABLE "work"."VerticalLandscapingPoint" ADD COLUMN IF NOT EXISTS "Svg_HAPoint" text NULL;
COMMENT ON COLUMN "work"."VerticalLandscapingPoint"."Svg_HAPoint" IS 'Горизонтальная точка привязки SVG';

-- Люки смотровых колодцев и решетки водоприемных колодцев
ALTER TABLE "work"."ManholesPoint" ADD COLUMN IF NOT EXISTS "Svg" text NULL;
COMMENT ON COLUMN "work"."ManholesPoint"."Svg" IS 'Путь к SVG иконкам';

ALTER TABLE "work"."ManholesPoint" ADD COLUMN IF NOT EXISTS "Svg_VAPoint" text NULL;
COMMENT ON COLUMN "work"."ManholesPoint"."Svg_VAPoint" IS 'Вертикальная точка привязки SVG';

ALTER TABLE "work"."ManholesPoint" ADD COLUMN IF NOT EXISTS "Svg_HAPoint" text NULL;
COMMENT ON COLUMN "work"."ManholesPoint"."Svg_HAPoint" IS 'Горизонтальная точка привязки SVG';

COMMENT ON TABLE "work"."PhotoFixPoint" IS 'Точки фотофиксации';

-- Создаем линейный слой фотофиксации
DROP TABLE IF EXISTS "work"."PhotoFixLine";
CREATE TABLE IF NOT EXISTS "work"."PhotoFixLine"(
    fid serial PRIMARY KEY NOT NULL,
    "PhotoName" text NULL,
	"TaskName" text NULL,
    "CreateDate" timestamptz NULL,
    "CreateAuthor" text NULL,
    "ChangeDate" timestamptz NULL,
    "ChangeAuthor" text NULL,
    "TaskGUID" uuid NULL,
    "Geometry" geometry(MultiLineString, 980077) NULL);

CREATE INDEX IF NOT EXISTS "PhotoFixLine_Geom_idx" ON "work"."PhotoFixLine" USING gist ("Geometry");

ALTER TABLE "work"."PhotoFixLine" OWNER to postgres;
GRANT ALL ON TABLE "work"."PhotoFixLine" TO mggt;
GRANT ALL ON TABLE "work"."PhotoFixLine" TO postgres;
GRANT ALL ON TABLE "work"."PhotoFixLine" TO mggt_editor;
GRANT SELECT ON TABLE "work"."PhotoFixLine" TO mggt_reader;

GRANT ALL ON SEQUENCE "work"."PhotoFixLine_fid_seq" TO mggt;
GRANT ALL ON SEQUENCE "work"."PhotoFixLine_fid_seq" TO postgres;
GRANT ALL ON SEQUENCE "work"."PhotoFixLine_fid_seq" TO mggt_editor;
GRANT SELECT ON SEQUENCE "work"."PhotoFixLine_fid_seq" TO mggt_reader;

COMMENT ON TABLE "work"."PhotoFixLine" IS 'Линии фотофиксации';
COMMENT ON COLUMN "work"."PhotoFixLine".fid IS 'Уникальный идентификатор записи (ключ таблицы)';
COMMENT ON COLUMN "work"."PhotoFixLine"."PhotoName" IS 'Название файла фото';
COMMENT ON COLUMN "work"."PhotoFixLine"."TaskName" IS 'Название папки задачи, в которой расположено фото';
COMMENT ON COLUMN "work"."PhotoFixLine"."CreateDate" IS 'Дата создания объекта';
COMMENT ON COLUMN "work"."PhotoFixLine"."CreateAuthor" IS 'Автор создания объекта';
COMMENT ON COLUMN "work"."PhotoFixLine"."ChangeDate" IS 'Дата последнего изменения объекта';
COMMENT ON COLUMN "work"."PhotoFixLine"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."PhotoFixLine"."TaskGUID" IS 'Идентификатор задачи в рамках которой редактируется этот объект';
COMMENT ON COLUMN "work"."PhotoFixLine"."ChangeAuthor" IS 'Автор последнего изменения объекта';
COMMENT ON COLUMN "work"."PhotoFixLine"."Geometry" IS 'Геометрия объекта';

ALTER TABLE "work"."YardPoly" ADD COLUMN IF NOT EXISTS "TotalCleaningArea" float8 NULL;
COMMENT ON COLUMN "work"."YardPoly"."TotalCleaningArea" IS 'Общая площадь уборки';

ALTER TABLE "work"."YardPoly" ADD COLUMN IF NOT EXISTS "TotalNoCleaningArea" float8 NULL;
COMMENT ON COLUMN "work"."YardPoly"."TotalNoCleaningArea" IS 'Общая площадь без уборки';

ALTER TABLE "work"."OznPoly" ADD COLUMN IF NOT EXISTS "TotalCleaningArea" float8 NULL;
COMMENT ON COLUMN "work"."OznPoly"."TotalCleaningArea" IS 'Общая площадь уборки';

ALTER TABLE "work"."OznPoly" ADD COLUMN IF NOT EXISTS "TotalNoCleaningArea" float8 NULL;
COMMENT ON COLUMN "work"."OznPoly"."TotalNoCleaningArea" IS 'Общая площадь без уборки';

ALTER TABLE "work"."OdhPoly" ADD COLUMN IF NOT EXISTS "TotalCleaningArea" float8 NULL;
COMMENT ON COLUMN "work"."OdhPoly"."TotalCleaningArea" IS 'Общая площадь уборки';

ALTER TABLE "work"."OdhPoly" ADD COLUMN IF NOT EXISTS "TotalNoCleaningArea" float8 NULL;
COMMENT ON COLUMN "work"."OdhPoly"."TotalNoCleaningArea" IS 'Общая площадь без уборки';

ALTER TABLE "work"."ImprovementObjectPoly" ADD COLUMN IF NOT EXISTS "TotalCleaningArea" float8 NULL;
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TotalCleaningArea" IS 'Общая площадь уборки';

ALTER TABLE "work"."ImprovementObjectPoly" ADD COLUMN IF NOT EXISTS "TotalNoCleaningArea" float8 NULL;
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."TotalNoCleaningArea" IS 'Общая площадь без уборки';

ALTER TABLE "work"."MafPoly" ADD COLUMN IF NOT EXISTS "SetManually" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."MafPoly"."SetManually" IS 'Признак того, что геометрия осевой линии элемента задана вручную';

ALTER TABLE "work"."OtherEnginConstructPoly" ADD COLUMN IF NOT EXISTS "SetManually" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."OtherEnginConstructPoly"."SetManually" IS 'Признак того, что геометрия осевой линии элемента задана вручную';

ALTER TABLE "work"."OtherFlatBuildingPoly" ADD COLUMN IF NOT EXISTS "SetManually" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."OtherFlatBuildingPoly"."SetManually" IS 'Признак того, что геометрия осевой линии элемента задана вручную';

ALTER TABLE "work"."TramRailsPoly" ADD COLUMN IF NOT EXISTS "SetManually" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."TramRailsPoly"."SetManually" IS 'Признак того, что геометрия осевой линии элемента задана вручную';

ALTER TABLE "work"."MarginPoly" ADD COLUMN IF NOT EXISTS "SetManually" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."MarginPoly"."SetManually" IS 'Признак того, что геометрия осевой линии элемента задана вручную';

ALTER TABLE "work"."SidewalksPoly" ADD COLUMN IF NOT EXISTS "SetManually" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."SidewalksPoly"."SetManually" IS 'Признак того, что геометрия осевой линии элемента задана вручную';

ALTER TABLE "work"."StopsPoly" ADD COLUMN IF NOT EXISTS "SetManually" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."StopsPoly"."SetManually" IS 'Признак того, что геометрия осевой линии элемента задана вручную';

ALTER TABLE "work"."CarriagewayPoly" ADD COLUMN IF NOT EXISTS "SetManually" bool DEFAULT FALSE;
COMMENT ON COLUMN "work"."CarriagewayPoly"."SetManually" IS 'Признак того, что геометрия осевой линии элемента задана вручную';


-- Создаем столбцы в рабочих слоях ОГХ
ALTER TABLE "work"."YardPoly" ADD COLUMN IF NOT EXISTS "Number" text NULL;
COMMENT ON COLUMN "work"."YardPoly"."Number" IS 'Номер задачи';

ALTER TABLE "work"."YardPoly" ADD COLUMN IF NOT EXISTS "Status" text NULL;
COMMENT ON COLUMN "work"."YardPoly"."Status" IS 'Текущий статус задачи';

ALTER TABLE "work"."YardPoly" ADD COLUMN IF NOT EXISTS "StatusNote" text NULL;
COMMENT ON COLUMN "work"."YardPoly"."StatusNote" IS 'Дополнительная информация по текущему статусу задачи (например текст ошибки из АСУ ОДС)';

ALTER TABLE "work"."OznPoly" ADD COLUMN IF NOT EXISTS "Number" text NULL;
COMMENT ON COLUMN "work"."OznPoly"."Number" IS 'Номер задачи';

ALTER TABLE "work"."OznPoly" ADD COLUMN IF NOT EXISTS "Status" text NULL;
COMMENT ON COLUMN "work"."OznPoly"."Status" IS 'Текущий статус задачи';

ALTER TABLE "work"."OznPoly" ADD COLUMN IF NOT EXISTS "StatusNote" text NULL;
COMMENT ON COLUMN "work"."OznPoly"."StatusNote" IS 'Дополнительная информация по текущему статусу задачи (например текст ошибки из АСУ ОДС)';

ALTER TABLE "work"."OdhPoly" ADD COLUMN IF NOT EXISTS "Number" text NULL;
COMMENT ON COLUMN "work"."OdhPoly"."Number" IS 'Номер задачи';

ALTER TABLE "work"."OdhPoly" ADD COLUMN IF NOT EXISTS "Status" text NULL;
COMMENT ON COLUMN "work"."OdhPoly"."Status" IS 'Текущий статус задачи';

ALTER TABLE "work"."OdhPoly" ADD COLUMN IF NOT EXISTS "StatusNote" text NULL;
COMMENT ON COLUMN "work"."OdhPoly"."StatusNote" IS 'Дополнительная информация по текущему статусу задачи (например текст ошибки из АСУ ОДС)';

ALTER TABLE "work"."ImprovementObjectPoly" ADD COLUMN IF NOT EXISTS "Number" text NULL;
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."Number" IS 'Номер задачи';

ALTER TABLE "work"."ImprovementObjectPoly" ADD COLUMN IF NOT EXISTS "Status" text NULL;
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."Status" IS 'Текущий статус задачи';

ALTER TABLE "work"."ImprovementObjectPoly" ADD COLUMN IF NOT EXISTS "StatusNote" text NULL;
COMMENT ON COLUMN "work"."ImprovementObjectPoly"."StatusNote" IS 'Дополнительная информация по текущему статусу задачи (например текст ошибки из АСУ ОДС)';


