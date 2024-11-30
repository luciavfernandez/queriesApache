-- Set the graph
SELECT set_graph('your_graph_name');

-- Q1. Transitive friends with a certain name
-- Input parameters: personId, firstName
SELECT 
    friend.id AS friendId,
    friend.last_name AS friendLastName,
    distance AS distanceFromPerson,
    friend.birthday AS friendBirthday,
    friend.creation_date AS friendCreationDate,
    friend.gender AS friendGender,
    friend.browser_used AS friendBrowserUsed,
    friend.location_ip AS friendLocationIp,
    friend.email AS friendEmails,
    friend.speaks AS friendLanguages,
    friend_city.name AS friendCityName,
    unis AS friendUniversities,
    companies AS friendCompanies
FROM 
    -- Match the person and their friends based on name and id
    vertex AS p, vertex AS friend
    -- Match the transitive paths of friendship (within 1 to 3 hops)
    MATCH (p)-[:KNOWS*1..3]-(friend)
    WHERE p.id = $personId AND friend.first_name = $firstName
    AND NOT p = friend
    
    -- Calculate the distance (shortest path length)
    WITH p, friend, min(length(path)) AS distance
    
    -- Order by distance, then by last name, and by ID
    ORDER BY distance, friend.last_name, CAST(friend.id AS INTEGER)
    LIMIT 20

    -- Collect additional information related to the friend's city, universities, and companies
    OPTIONAL MATCH (friend)-[:IS_LOCATED_IN]->(friend_city:City)
    OPTIONAL MATCH (friend)-[studyAt:STUDY_AT]->(uni:University)-[:IS_LOCATED_IN]->(uniCity:City)
    WITH 
        friend, 
        friend_city, 
        distance, 
        collect(CASE 
            WHEN uni.name IS NULL THEN NULL
            ELSE ARRAY[uni.name, studyAt.class_year, uniCity.name]
            END) AS unis
    
    OPTIONAL MATCH (friend)-[workAt:WORK_AT]->(company:Company)-[:IS_LOCATED_IN]->(company_country:Country)
    WITH 
        friend, 
        friend_city, 
        distance, 
        unis, 
        collect(CASE 
            WHEN company.name IS NULL THEN NULL
            ELSE ARRAY[company.name, workAt.work_from, company_country.name]
            END) AS companies
    
    -- Return the final results
    RETURN 
        friend.id, 
        friend.last_name, 
        distance, 
        friend.birthday, 
        friend.creation_date, 
        friend.gender, 
        friend.browser_used, 
        friend.location_ip, 
        friend.email, 
        friend.speaks, 
        friend_city.name, 
        unis, 
        companies
ORDER BY 
    distance ASC, 
    friend.last_name ASC, 
    CAST(friend.id AS INTEGER) ASC
LIMIT 20;
