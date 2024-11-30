-- Set the graph context (assuming your graph name is 'your_graph_name')
SELECT set_graph('your_graph_name');

-- Q3. Friends and friends of friends that have been to given countries
-- Input parameters: personId, countryXName, countryYName, startDate, endDate
SELECT 
    friend.id AS friendId,
    friend.first_name AS friendFirstName,
    friend.last_name AS friendLastName,
    xCount,
    yCount,
    xCount + yCount AS xyCount
FROM 
    -- Match the person and the countries
    vertex AS countryX, vertex AS countryY, vertex AS person, vertex AS city, vertex AS friend, vertex AS message, vertex AS country
    -- Match the country and cities
    MATCH (countryX)-[:IS_LOCATED_IN]->(city)-[:IS_PART_OF]->(country)
    MATCH (countryY)-[:IS_LOCATED_IN]->(city)-[:IS_PART_OF]->(country)
    WHERE country.name IN [countryX.name, countryY.name] 
      AND person.id = $personId
    LIMIT 1
    -- Collect cities in both countries
    WITH person, countryX, countryY, collect(city) AS cities

    -- Match the person and friends (1 to 2 hops)
    MATCH (person)-[:KNOWS*1..2]-(friend)-[:IS_LOCATED_IN]->(city)
    WHERE NOT person = friend AND NOT city IN cities

    -- Match messages and check creation date within the range
    MATCH (friend)<-[:HAS_CREATOR]-(message)-[:IS_LOCATED_IN]->(country)
    WHERE message.creation_date >= $startDate 
      AND message.creation_date <= $endDate
      AND country.name IN [countryX.name, countryY.name]
    
    -- Count the messages for each country
    WITH friend,
         SUM(CASE WHEN country.name = countryX.name THEN 1 ELSE 0 END) AS xCount,
         SUM(CASE WHEN country.name = countryY.name THEN 1 ELSE 0 END) AS yCount
    WHERE xCount > 0 AND yCount > 0

    -- Return the final results ordered by xyCount and friendId
    RETURN 
        friend.id AS friendId,
        friend.first_name AS friendFirstName,
        friend.last_name AS friendLastName,
        xCount,
        yCount,
        xCount + yCount AS xyCount
    ORDER BY xyCount DESC, friendId ASC
    LIMIT 20;
