use master 
if exists (select * from sys.databases where name = 'rapphim')
	drop database rapphim
go 
create database rapphim
on  (NAME='rapphim_data' , FILENAME ='C:\SQL\rapphim.MDF')
log on (NAME ='rapphim_log',FILENAME='C:\SQL\rapphim.LDF')
go
use rapphim
--cau 1: tao table va nhap du lieu 
go
if exists (select * from sys.objects where name = 'theloai')
	drop table theloai
go 
create table theloai(
	matl char(2) not null,
	tentl nvarchar(20)
)
go
if exists (select * from sys.objects where name = 'phim')
	drop table phim
go 
create table phim(
	maphim char(3)not null ,
	tenphim nvarchar(20),
	solanchieu int ,
	matl char(2)
)
go
if exists (select * from sys.objects where name = 'rap')
	drop table rap
go 
create table rap(
	marap char(3)not null ,
	tenrap nvarchar(20),
	diachi nvarchar(20)
)
go
if exists (select * from sys.objects where name = 'lichchieu')
	drop table lichchieu
go 
create table lichchieu(
	maxc int not null , 
	marap char(3),
	maphim char(3),
	ngaychieu datetime,
	soluongve int,
	giave bigint,
)
go
insert into theloai values
	('L1',N'hanh dong'),
	('L2',N'chien tranh'),
	('L3',N'hai')
go
insert into phim values 
	('P01',N'bay rong',NULL,'L1'),
	('P02',N'canh dong hoang',NULL,'L2'),
	('P03',N'khi dan ong co bau',NULL,'L3'),
	('P04',N'dong mau anh hung',NULL,'L1'),
	('P05',N'biet dong sai gon',NULL,'L2')
go
insert into rap values
	('R01',N'thang long',N'tan binh'),
	('R02',N'hung vuong',N'quan 10'),
	('R03',N'thong nhat',N'quan 1'),
	('R04',N'giai phong',N'phu nhuan')
go
insert into lichchieu values
	('01','R01','P01','2013-04-01 00:00:00:000',150,120000),
	('02','R03','P01','2013-04-01 00:00:00:000',130,110000),
	('03','R04','P02','2013-04-30 00:00:00:000',250,170000),
	('04','R02','P02','2013-05-01 00:00:00:000',100,180000),
	('05','R03','P03','2013-05-19 00:00:00:000',350,140000),
	('06','R02','P03','2013-06-01 00:00:00:000',160,160000),
	('07','R01','P04','2013-09-02 00:00:00:000',90,120000)
go
--Câu 2: Thực hiện tạo các ràng buộc sau bằng ngôn ngữ SQL 
--	Các ràng buộc khóa chính, khóa ngoại 
alter table theloai 
	add constraint pk_theloai primary key (matl)
alter table phim 
	add constraint pk_phim primary key (maphim)
alter table phim 
	add constraint fk_phim_theloai foreign key (matl) references theloai(matl)
alter table rap 
	add constraint pk_rap primary key (marap)
alter table lichchieu 
	add constraint pk_lichchieu primary key (maxc)
alter table lichchieu 
	add constraint fk_lichchieu_rap foreign key (marap) references rap(marap)
alter table lichchieu 
	add constraint fk_lichchieu_phim foreign key (maphim) references phim(maphim)
--	Số lượng vé của một phim chiếu từ 50 đến 500
alter table lichchieu 
	add constraint ck_soluongve check(soluongve between 50 and 500)
go
--	Giá vé từ 100000 trở lên và bội số của 10. 
alter table lichchieu
	add constraint ck_giave check(giave > 100000 and giave % 10 = 0 )
go 

--Câu 3: Thực hiện các truy vấn sau bằng ngôn ngữ SQL  (5 điểm)  
--a.	Tạo truy vấn tìm phim nào chiếu nhiều lần nhất. 
--Thông tin hiển thị gồm MAPHIM, TENPHIM, SOLANCHIEU (1điểm)
select top (1) with ties p.maphim , p.tenphim , count(p.maphim) as solanchieu  
from phim p , lichchieu l 
where p.maphim = l.maphim 
group by p.maphim , p.tenphim
order by solanchieu desc
--b.	Tạo truy vấn tìm các rạp chưa chiếu các phim thuộc thể loại HÀI. 
--Thông tin hiển thị gồm MARAP, TENRAP (1điểm)
select r.marap , r.tenrap
from rap r , lichchieu l
where r.marap = l.marap 
and l.maphim in (select p.maphim from phim p where p.matl in
				(select t.matl from theloai t where t.tentl = N'hai')) 
--c.	Tạo truy vấn cập nhật số lần chiếu của các phim vào table PHIM. (1.5 điểm)
update phim 
set phim.solanchieu = (select count(maphim) from lichchieu where phim.maphim = lichchieu.maphim group by maphim)
--d.	Tạo truy vấn thống kê tổng số doanh thu của từng phim theo từng năm (phim nào chưa công chiếu thì doanh thu = 0). Thông tin hiển thị gồm : TÊN PHIM, NĂM, TỔNG SỐ 
--LƯỢNG VÉ, TỔNG DOANH THU (Tổng doanh thu = Tổng số lượng vé * giá vé)  (1.5điểm)
select p.tenphim , year(l.ngaychieu) as nam , sum(l.soluongve) as [tong luong ve] ,(case  when p.solanchieu is NULL then 0
																									else sum(l.giave*l.soluongve) end) as [tongdoanhthu] 
from phim p 
left join lichchieu l on p.maphim = l.maphim 
group by p.tenphim , l.ngaychieu ,p.solanchieu
 
