-- authors
select count(distinct value) from item_property ip 
where ip.property = 'author' -- 988

select count(distinct value) from item_property ip 
where ip.property like '%author' -- 1231

select distinct property from item_property ip 
where ip.property like '%author' -- author and alt_author

select distinct value from item_property ip 
where ip.property = 'alt_author' -- 246 are alt names for authors, TODO how to identify homonyms?

select ip.value as alt_author, i.filename, count(distinct ip2.value)
from item_property ip 
inner join item i on ip.item_id = i.id 
left join item_property ip2 on ip2.item_id = i.id and ip2.property = 'author'
where ip.property = 'alt_author' -- 246 are alt names for authors, TODO how to identify homonyms?
group by 1, 2 -- too many with more than one, homonyms are a TODO for the future

-- creating data tables
drop table if exists book;
drop table if exists author;
drop table if exists author_book;

create table author (
id integer primary key,
name varchar(100));

insert into author (name) 
select distinct value from item_property ip 
where ip.property = 'author' -- 988

select * from author; -- TODO maybe having an 'alt' tag, optional, to load alt_author to this too?

-- titles
select distinct value from item_property ip 
where ip.property = 'title' -- 920

select value from item_property ip 
where ip.property = 'title' -- 999

select max(ip.value) from item_property ip
where ip.property = 'title'
group by ip.item_id -- 988

-- are there books with duplicate volume, isbn or year? no!
select ip.property, count(distinct ip.item_id) from item_property ip
where ip.property in ('volume', 'isbn', 'year')
group by ip.item_id, ip.property
having count(distinct ip.item_id) > 1

-- and publisher? no as well, but a fk for this would be preferrable... TODO
select ip.property, count(distinct ip.item_id) from item_property ip
where ip.property = 'publisher'
group by ip.item_id, ip.property
having count(distinct ip.item_id) > 1

-- book basic structure (v1)
create table book (
item_id integer primary key,
main_title varchar(100) not null,
main_subtitle varchar(100),
volume varchar(20),
publisher varchar(100),
isbn varchar(100),
'year' varchar(20));

insert into book 
select ip.item_id, max(ip.value) as title, max(ip2.value) as subtitle, 
	max(ip3.value) as volume, max(ip4.value) as publisher, 
	max(ip5.value) as isbn, max(ip6.value) as 'year' -- TODO some 'year' are not good, review
from item_property ip
left join item_property ip2 on ip.item_id = ip2.item_id and ip2.property = 'subtitle'
left join item_property ip3 on ip.item_id = ip3.item_id and ip3.property = 'volume'
left join item_property ip4 on ip.item_id = ip4.item_id and ip4.property = 'publisher'
left join item_property ip5 on ip.item_id = ip5.item_id and ip5.property = 'isbn'
left join item_property ip6 on ip.item_id = ip6.item_id and ip6.property = 'year'
where ip.property = 'title'
group by ip.item_id -- 988

-- author x book
-- TODO this approach would present a problem for homonyms, but how could this be prevented if not by adding info to authors?
-- TODO I would love a 'person' entity, that could refer to translator, contributor, author, etc.
drop table if exists author_book; 

create table author_book as
select b.item_id as item_id, a.id as author_id
, b.main_title, a.name
from item_property ip 
inner join author a on ip.value = a.name
inner join book b on ip.item_id = b.item_id
where ip.property = 'author'

select * from author_book -- 1388

-- books with more than one author
select b.main_title, count(*) as nr_authors
from author_book ab
inner join book b on ab.item_id = b.item_id
group by b.main_title
having count(*) > 1
order by 2 desc

--> 

-- books with no fiction/nonfiction subtype TOFIX?
-- better yet: fiction, nonfiction, both, other
select b2.*, value from book b2 
left join item_property ip2 on b2.item_id = ip2.item_id and ip2.property ='subtype'
where b2.item_id not in 
(select i.id from item i
inner join item_property ip on i.id = ip.item_id and ip.property = 'subtype' and ip.value in ('fiction', 'nonfiction')
group by ip.item_id) 