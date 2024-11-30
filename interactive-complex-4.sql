-- Set the graph context (assuming your graph name is 'your_graph_name')
SELECT set_graph('your_graph_name');

-- Q4. New topics
-- Input parameters: personId, startDate, endDate
SELECT 
    tag.name AS tagName, 
    postCount
FROM 
    -- Match the person, their friends, posts, and tags
    vertex AS person, vertex AS friend, vertex AS post, vertex AS tag
    -- Match the relationships
    MATCH (person)-[:KNOWS]-(friend)-[:HAS_CREATOR]->(post)-[:HAS_TAG]->(tag)
    WHERE person.id = $personId
    -- Check if post creation date is within the range
    WITH tag, post,
         CASE WHEN $startDate <= post.creation_date AND post.creation_date < $endDate THEN 1 ELSE 0 END AS valid,
         CASE WHEN post.creation_date < $startDate THEN 1 ELSE 0 END AS inValid
    -- Aggregate counts for valid and invalid posts
    WITH tag, SUM(valid) AS postCount, SUM(inValid) AS inValidPostCount
    WHERE postCount > 0 AND inValidPostCount = 0
    -- Return the tag and its post count, ordered by post count and tag name
    RETURN tag.name AS tagName, postCount
    ORDER BY postCount DESC, tagName ASC
    LIMIT 10;
