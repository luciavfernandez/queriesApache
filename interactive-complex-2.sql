-- Set the graph context (assuming your graph name is 'your_graph_name')
SELECT set_graph('your_graph_name');

-- Q2. Recent messages by your friends
-- Input parameters: personId, maxDate
SELECT 
    friend.id AS personId,
    friend.first_name AS personFirstName,
    friend.last_name AS personLastName,
    message.id AS postOrCommentId,
    COALESCE(message.content, message.image_file) AS postOrCommentContent,
    message.creation_date AS postOrCommentCreationDate
FROM 
    -- Match the person and their friends
    vertex AS p, vertex AS friend, vertex AS message
    -- Match the "KNOWS" relationship and the "HAS_CREATOR" relationship
    MATCH (p)-[:KNOWS]-(friend)-[:HAS_CREATOR]->(message)
    WHERE p.id = $personId 
      AND message.creation_date <= $maxDate
    ORDER BY 
        message.creation_date DESC, 
        CAST(message.id AS INTEGER) ASC
    LIMIT 20;
