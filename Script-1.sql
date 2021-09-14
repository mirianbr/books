-- Total books: 969
select i.id, i.filename
from item i;

-- No books without titles
select i.id, i.filename, title.value
from item i 
left join item_property title on i.id = title.item_id and title.property = 'title'
where title.value is null;

-- 10 books with more than one title -- does it make sense? Shouldn't it be alt_title instead?
select i.id, filename, title.value 
from (
select i.id, i.filename, count(distinct title.id) as tot_titles
from item i 
left join item_property title on i.id = title.item_id and title.property = 'title'
group by i.id, i.filename
having count(distinct title.id) > 1) i
inner join item_property title on i.id = title.item_id and title.property = 'title'
order by 1;

-- A summary with one of each these properties: title, author, subtype, publisher, language
select i.id, i.filename, 
	max(title.value) as title,
	max(author.value) as author,
	max(subtype.value) as subtype,
	max(publisher.value) as publisher,
	max(lang.value) as lang
from item i 
left join item_property title on i.id = title.item_id and title.property = 'title'
left join item_property author on i.id = author.item_id and author.property = 'author'
left join item_property subtype on i.id = subtype.item_id and subtype.property = 'subtype'
left join item_property publisher on i.id = publisher.item_id and publisher.property = 'publisher'
left join item_property lang on i.id = lang.item_id and lang.property = 'lang'
group by i.id, i.filename;

-- How many with more than one language?
select i.id, i.filename, 
	count(distinct lang.value),
	(select group_concat(lang.value, ', ') from item_property lang
	where lang.item_id = i.id and lang.property = 'lang') as languages
from item i 
left join item_property lang on i.id = lang.item_id and lang.property = 'lang'
group by i.id, i.filename
having count(distinct lang.value) > 1;

-- Most popular languages?
select lang.value, count(distinct i.id)
from item i 
left join item_property lang on i.id = lang.item_id and lang.property = 'lang'
group by lang.value
order by 2 desc
limit 10;

-- Most popular keywords?
select lower(kw.value), count(distinct i.id)
from item i 
left join item_property kw on i.id = kw.item_id and kw.property = 'keyword'
group by lower(kw.value)
order by 2 desc
limit 25;

-- Most popular keywords for fiction and nonfiction
select lower(kw.value), count(distinct i.id)
from item i 
left join item_property kw on i.id = kw.item_id and kw.property = 'keyword'
inner join item_property st on i.id = st.item_id and st.property = 'subtype' and st.value = 'fiction' 
group by lower(kw.value)
order by 2 desc
limit 10;

select lower(kw.value), count(distinct i.id)
from item i 
left join item_property kw on i.id = kw.item_id and kw.property = 'keyword'
inner join item_property st on i.id = st.item_id and st.property = 'subtype' and st.value = 'nonfiction'
group by lower(kw.value)
order by 2 desc
limit 10;


-- Fiction vs non-fiction? (Note: there's intersection, and that's fine)
-- FIXME however, they should occupy one line each
-- FIXME and Contos Gauchescos is not a subtype!
select subtype.value, count(distinct i.id)
from item i 
left join item_property subtype on i.id = subtype.item_id and subtype.property = 'subtype'
group by subtype.value
order by 2 desc;

-- Most popular authors?
select author.value, count(distinct i.id)
from item i 
left join item_property author on i.id = author.item_id and author.property = 'author'
group by author.value
order by 2 desc
limit 10;

-- Top publishers?
select publisher.value, count(distinct i.id)
from item i 
left join item_property publisher on i.id = publisher.item_id and publisher.property = 'publisher'
group by publisher.value
order by 2 desc
limit 25;

-- All publishers
-- FIXME differences in spaces, case, hyphenation
-- FIXME "Editores", "Editora", "Press", "Books", "S/A", "Ltda" vs none of these
-- FIXME typos: Berrett-Koehler Publishers vs Berrett-Koheler Publishers
select distinct publisher.value
from item i 
left join item_property publisher on i.id = publisher.item_id and publisher.property = 'publisher'
order by 1;
