DELIMITER $$

CREATE FUNCTION `getClique`(ratedU int, ratingU int) RETURNS double
BEGIN
   declare a double;
   declare done INT DEFAULT 0;
   DECLARE cur1 CURSOR FOR SELECT probability FROM users_clique where rating_user=ratingU and rated_user = ratedU;
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
   OPEN cur1;
   FETCH cur1 INTO a;
   close cur1;
   if done=1 then
      return 0;
   else
      return a;
   end if;
END $$

DELIMITER ;


DELIMITER $$

CREATE FUNCTION getSumWeight(id int, uid int) RETURNS int(11)
BEGIN
   declare a double;
   declare done INT DEFAULT 0;
   DECLARE cur1 CURSOR FOR SELECT sum(distinct weight) from object_rating_all where oid=id and userid=uid;
   DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
   OPEN cur1;
   FETCH cur1 INTO a;
   close cur1;
   if done=1 then
      return 0;
   else
      return a;
   end if;
END $$

DELIMITER ;


DELIMITER $$

CREATE FUNCTION updateRatings(ratedObject int) RETURNS int(11)
BEGIN

delete from object_rating where uid=ratedObject;

insert into object_rating (uid, userid, value)
select ratedObject, b.userid, case when getSumWeight(a.oid, a.userid) = 0 then 0 else avg((1 - getClique(b.userid, a.userid)) * answer * weight / getSumWeight(a.oid, a.userid)) end
from object_rating_all a, objects b
where a.oid = b.uid and oid=ratedObject
group by a.oid, b.userid
order by a.oid;

return 1;

END $$

DELIMITER ;