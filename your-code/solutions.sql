use publications;
-- CLEAN CHALLENGE 1
-- Step 1 (Checked and OK)  34 rows
select t.title_id, ta.au_id, (IFNULL(t.advance, 0) * IFNULL(ta.royaltyper, 0))/100 as advance,   (((IFNULL(t.price, 0) * IFNULL(s.qty, 0) * IFNULL(t.royalty, 0)) / 100) * (IFNULL(ta.royaltyper, 0) / 100)) as sales_royalty
from sales s 
left join titles t on s.title_id = t.title_id
left join titleauthor ta on ta.title_id = s. title_id
inner join authors a on ta.au_id = a.au_id;

-- STEP 2 -- 24 rows
select title_id, au_id, sum(advance) as sum_adv, sum(sales_royalty) as sal_roy
from (
	select t.title_id, ta.au_id, (IFNULL(t.advance, 0) * IFNULL(ta.royaltyper, 0))/100 as advance,   (((IFNULL(t.price, 0) * IFNULL(s.qty, 0) * IFNULL(t.royalty, 0)) / 100) * (IFNULL(ta.royaltyper, 0) / 100)) as sales_royalty
	from sales s 
	left join titles t on s.title_id = t.title_id
	left join titleauthor ta on ta.title_id = s. title_id
	inner join authors a on ta.au_id = a.au_id
) tmp 
group by title_id, au_id ;


-- STEP 3
-- Author ID
-- Profits of each author by aggregating the advance and total royalties of each title
-- Sort the output based on a total profits from high to low, and limit the number of rows to 3.

select au_id, sum(sum_adv + sal_roy) as profits
from (

	select title_id, au_id, sum(advance) sum_adv, sum(sales_royalty) sal_roy
	from (
		select t.title_id, ta.au_id, (IFNULL(t.advance, 0) * IFNULL(ta.royaltyper, 0))/100 as advance,   (((IFNULL(t.price, 0) * IFNULL(s.qty, 0) * IFNULL(t.royalty, 0)) / 100) * (IFNULL(ta.royaltyper, 0) / 100)) as sales_royalty
		from sales s 
		left join titles t on s.title_id = t.title_id
		left join titleauthor ta on ta.title_id = s. title_id
		inner join authors a on ta.au_id = a.au_id
	) tmp 
	group by title_id, au_id 

) tmp2
group by au_id
order by profits desc
limit 3;

-- Challenge 2
--- first query 
CREATE TEMPORARY TABLE IF NOT EXISTS adv_sales_royalty AS
 
	(
    select t.title_id, ta.au_id, (IFNULL(t.advance, 0) * IFNULL(ta.royaltyper, 0))/100 as advance,   (((IFNULL(t.price, 0) * IFNULL(s.qty, 0) * IFNULL(t.royalty, 0)) / 100) * (IFNULL(ta.royaltyper, 0) / 100)) as sales_royalty
	from sales s 
	left join titles t on s.title_id = t.title_id
	left join titleauthor ta on ta.title_id = s. title_id
	inner join authors a on ta.au_id = a.au_id 
    );


--  second query

CREATE TEMPORARY TABLE IF NOT EXISTS final AS
 
	(
	 select title_id, au_id, sum(advance) as sum_adv, sum(sales_royalty) as sal_roy
		from adv_sales_royalty tmp2
		group by title_id, au_id 
    );


-- Part 3 

select au_id, sum(sum_adv + sal_roy) as profits
from final tmp2
group by au_id
order by profits desc
limit 3;

-- Challenge 3

CREATE TABLE most_profiting_authors 

select au_id, sum(sum_adv + sal_roy) as profits
from final tmp2
group by au_id
order by profits desc;

select * from most_profiting_authors;