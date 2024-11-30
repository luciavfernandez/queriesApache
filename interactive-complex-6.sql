-- Set the graph context (assuming your graph name is 'your_graph_name')
SELECT set_graph('your_graph_name');

-- Q6. Tag co-occurrence
-- Input parameters: personId, tagName
SELECT 
    tagName, 
    postCount
FROM 
    -- Match the known tag by name
    vertex AS knownTag, vertex AS person, vertex AS friend, vertex AS post, vertex AS tag
    -- Find the tag with the given name
    MATCH (knownTag)
    WHERE knownTag.name = $tagName
    WITH knownTag.id AS knownTagId
    -- Match the person and their friends (1 to 2 hops)
    MATCH (person)-[:KNOWS*1..2]-(friend)
    WHERE person.id = $personId AND NOT person = friend
    WITH knownTagId, collect(DISTINCT friend) AS friends
    -- Unwind the friends and match posts with co-occurring tags
    UNWIND friends AS f
    MATCH (f)<-[:HAS_CREATOR]-(post)-[:HAS_TAG]->(t:Tag{id: knownTagId}),
          (post)-[:HAS_TAG]->(tag:Tag)
    WHERE NOT t = tag
    -- Aggregate the count of posts for each tag co-occurring with the known tag
    WITH tag.name AS tagName, COUNT(post) AS postCount
    -- Return the tag and the count of posts with the tag co-occurring with the known tag
    RETURN tagName, postCount
    ORDER BY postCount DESC, tagName ASC
    LIMIT 10;
