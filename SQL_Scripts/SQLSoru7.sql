/*Senaryo:
  EmployeeHierarchy CTE'si, çalışanların organizasyon hiyerarşisini oluşturur.
  İlk bölümde, en tepe düzeydeki çalışanlar (yani, organizasyon düğümünün üstünde olanlar) seçilir ve başlangıç noktası olarak kullanılır.
  İkinci bölümde ise, her bir çalışan için, onun organizasyon düğümünün bir üstünde olan çalışanlar bulunur ve hiyerarşi yolu güncellenir. 
  Sonuç olarak, tüm çalışanların organizasyon hiyerarşisi ve seviyeleri elde edilir.
 */


;WITH EmployeeHierarchy AS (
    SELECT 
        BusinessEntityID, 
        JobTitle, 
        ISNULL(OrganizationNode,'/') as OrganizationNode,
        CAST(JobTitle AS VARCHAR(MAX)) AS HierarchyPath,
        0 AS Level
    FROM HumanResources.Employee
    WHERE OrganizationNode.GetAncestor(1) IS NULL -- En tepe

    UNION ALL

    SELECT 
        e.BusinessEntityID, 
        e.JobTitle, 
        e.OrganizationNode,
        eh.HierarchyPath + ' > ' + CAST(e.JobTitle AS VARCHAR(MAX)),
        eh.Level + 1
    FROM HumanResources.Employee e
    INNER JOIN EmployeeHierarchy eh 
        ON e.OrganizationNode.GetAncestor(1) = eh.OrganizationNode
)
SELECT * FROM EmployeeHierarchy 
ORDER BY OrganizationNode;