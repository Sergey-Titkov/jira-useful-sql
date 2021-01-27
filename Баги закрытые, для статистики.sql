WITH 
root_issues(id) as(
select 19
),
jiraissues(id) as (
select IL.SOURCE jiraissue_id
from ISSUELINK IL
inner join root_issues rt_is
on rt_is.id =il.DESTINATION 
union 
select IL.DESTINATION jiraissue_id
from ISSUELINK IL 
inner join root_issues rt_is
on rt_is.id =il.SOURCE 
)
SELECT 
 CONCAT('https://???????/browse/',  pt.pkey, '-',je.issuenum) jira_key
,ie.pname
,je.SUMMARY
,i_s.pname
,min(cg_b.CREATED) in_progress  -- Дата первого IN PROGRESS!!!
,max(cg_e.CREATED) done         -- Дата последнего Done!!! Мы же понимаем что задачу могут гонять туда сюда
,DATEDIFF(day, min(cg_b.CREATED), max(cg_e.CREATED)) - DateDiff(WK, min(cg_b.CREATED), max(cg_e.CREATED))*2+1 work_day_diff

FROM  jiraissues

INNER JOIN jiraissue je 
on je.id = jiraissues.id

inner join project pt
on je.PROJECT = pt.ID

inner join issuetype ie 
on je.issuetype = ie.ID

inner join issuestatus i_s
on je.issuestatus=i_s.ID

-- Вынимаем когда создали
inner join changegroup cg_b on cg_b.issueid = je.id --and cg_b.CREATED > EOMONTH('2019-12-31') -- Это если надо по датам сделать отсечку
inner join changeitem ci_b on ci_b.groupid = cg_b.id AND ci_b.FIELDTYPE='jira' AND ci_b.FIELD='status' and ci_b.NEWSTRING like 'IN PROGRESS' -- Статутсы даны для примера
-- Когда закрыли
inner join changegroup cg_e on cg_e.issueid = je.id --and cg_e.CREATED > EOMONTH('2019-12-31')
inner join changeitem ci_e on ci_e.groupid = cg_e.id AND ci_e.FIELDTYPE='jira' AND ci_e.FIELD='status' and ci_e.NEWSTRING like 'DONE' -- Статутсы даны для примера

where
  ie.pname like 'Bug' 
group by
 CONCAT('https://???????/browse/',  pt.pkey, '-',je.issuenum) 
,ie.pname
,je.SUMMARY
,i_s.pname

order by jira_key
