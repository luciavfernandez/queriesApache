-- Set the graph context (assuming your graph name is 'your_graph_name')
SELECT set_graph('your_graph_name');

-- Q5. New groups
-- Input parameters: personId, minDate
SELECT 
    forum.title AS forumName,
    postCount
FROM 
    -- Match the person and their friends (1 to 2 hops)
    vertex AS person, vertex AS friend, vertex AS forum, vertex AS post, edge AS membership
    MATCH (person)-[:KNOWS*1..2]-(friend)
    WHERE person.id = $personId AND NOT person = friend
    WITH DISTINCT friend
    -- Match friends' forum memberships after minDate
    MATCH (friend)<-[membership:HAS_MEMBER]-(forum)
    WHERE membership.join_date > $minDate
    WITH forum, collect(friend) AS friends
    -- Optional: Match posts that are related to the forums and count them
    OPTIONAL MATCH (friend)<-[:HAS_CREATOR]-(post)<-[:CONTAINER_OF]-(forum)
    WHERE friend IN friends
    -- Count the number of posts in each forum
    WITH forum, COUNT(post) AS postCount
    -- Return the forum name and the post count
    RETURN forum.title AS forumName, postCount
    ORDER BY postCount DESC, forum.id ASC
    LIMIT 20;
