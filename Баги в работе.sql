WITH 
root_issues(id) as(
select 19 -- ID тикета к которому привязаны тикеты
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
), bug_lists(jira_key, issue_type, issue_summary, issue_status, in_progress, work_day_diff) as(
SELECT 
 CONCAT('!!!Вписать utl jira!!!',  pt.pkey, '-',je.issuenum) jira_key
,ie.pname
,je.SUMMARY
,i_s.pname
,min(cg_b.CREATED) in_progress  -- Дата первого IN PROGRESS!!!
,DATEDIFF(day, min(cg_b.CREATED),  getDate()  ) - DateDiff(WK, min(cg_b.CREATED), getDate())*2+1 work_day_diff

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
inner join changegroup cg_b on cg_b.issueid = je.id --and cg_b.CREATED > EOMONTH('2019-12-31') -- Это если надо по датам сделать отсечку, так же можно сделать сколзящее окно
inner join changeitem ci_b on ci_b.groupid = cg_b.id AND ci_b.FIELDTYPE='jira' AND ci_b.FIELD='status' and ci_b.NEWSTRING like 'IN PROGRESS' -- Статутсы даны для примера
where
  ie.pname like 'Bug' 
  and i_s.pname in ('In Progress')
group by
 CONCAT('!!!Вписать utl jira!!!',  pt.pkey, '-',je.issuenum) 
,ie.pname
,je.SUMMARY
,i_s.pname
)
select *
from bug_lists
order by jira_key
