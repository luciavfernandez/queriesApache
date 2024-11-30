-- Set the graph context (assuming your graph name is 'your_graph_name')
SELECT set_graph('your_graph_name');

-- Q7. Recent Likers
-- Input parameter: personId
SELECT 
    liker.id AS personId,
    liker.first_name AS personFirstName,
    liker.last_name AS personLastName,
    latestLike.likeTime AS likeCreationDate,
    latestLike.msg_id AS commentOrPostId,
    COALESCE(latestLike.content, latestLike.image_file) AS commentOrPostContent,
    FLOOR(EXTRACT(epoch FROM (latestLike.likeTime - latestLike.msg_creationDate)) / 60.0) AS minutesLatency,
    NOT EXISTS (MATCH (liker)-[:KNOWS]-(person) WHERE person.id = $personId) AS isNew
FROM 
    vertex AS person, vertex AS message, vertex AS liker, edge AS like
-- Match the relationships between the person, messages, and likers
MATCH (person)-[:HAS_CREATOR]->(message)<-[:LIKES]-(liker)
WHERE person.id = $personId
-- Gather the like creation time and sort by the like time in descending order
WITH liker, message, like.creation_date AS likeTime, person
ORDER BY likeTime DESC, message.id ASC
-- Collect the latest like for each message
WITH liker, HEAD(COLLECT(ROW(message.id AS msg_id, likeTime, message.content AS content, message.image_file AS image_file, message.creation_date AS msg_creationDate))) AS latestLike, person
-- Return the necessary fields
RETURN 
    liker.id AS personId,
    liker.first_name AS personFirstName,
    liker.last_name AS personLastName,
    latestLike.likeTime AS likeCreationDate,
    latestLike.msg_id AS commentOrPostId,
    latestLike.content AS commentOrPostContent,
    FLOOR(EXTRACT(epoch FROM (latestLike.likeTime - latestLike.msg_creationDate)) / 60.0) AS minutesLatency,
    NOT EXISTS (MATCH (liker)-[:KNOWS]-(person) WHERE person.id = $personId) AS isNew
ORDER BY 
    likeCreationDate DESC,
    TO_INTEGER(liker.id) ASC
LIMIT 20;
