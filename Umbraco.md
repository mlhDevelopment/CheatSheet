# Umbraco v9

## Node Object Type table
A reference table based on C# constants in the source code Constants-ObjectTypes.cs file. Useful when determining node types.

    CREATE TABLE #NodeObjectType (TypeId uniqueidentifier not null, Name varchar(100))
    -- or DECLARE @NodeObjectType TABLE (TypeId uniqueidentifier not null, Name varchar(100))
    INSERT INTO #NodeObjectType(Name, TypeId)
    VALUES ('DataTypeContainer', '521231E3-8B37-469C-9F9D-51AFC91FEB7B')
        ,('DocumentTypeContainer', '2F7A2769-6B0B-4468-90DD-AF42D64F7F16')
        ,('MediaTypeContainer', '42AEF799-B288-4744-9B10-BE144B73CDC4')
        ,('ContentItem', '10E2B09F-C28B-476D-B77A-AA686435E44A')
        ,('ContentItemType', '7A333C54-6F43-40A4-86A2-18688DC7E532')
        ,('ContentRecycleBin', '01BB7FF2-24DC-4C0C-95A2-C24EF72BBAC8')
        ,('DataType', '30A2A501-1978-4DDB-A57B-F7EFED43BA3C')
        ,('Document', 'C66BA18E-EAF3-4CFF-8A22-41B16D66A972')
        ,('DocumentBlueprint', '6EBEF410-03AA-48CF-A792-E1C1CB087ACA') -- added in v8?
        ,('DocumentType', 'A2CB7800-F571-4787-9638-BC48539A0EFB')
        ,('Media', 'B796F64C-1F99-4FFB-B886-4BF4BC011A9C')
        ,('MediaRecycleBin', 'CF3D8E34-1C1C-41e9-AE56-878B57B32113')
        ,('MediaType', '4EA4382B-2F5A-4C2B-9587-AE9B3CF3602E')
        ,('Member', '39EB0F98-B348-42A1-8662-E7EB18487560')
        ,('MemberGroup', '366E63B9-880F-4E13-A61C-98069B029728')
        ,('MemberType', '9B5416FB-E72F-45A9-A07B-5A9A2709CE43')
        ,('Stylesheet', '9F68DA4F-A3A8-44C2-8226-DCBD125E4840')
        ,('StylesheetProperty', '5555da4f-a123-42b2-4488-dcdfb25e4111')
        ,('SystemRoot', 'EA7D8624-4CFE-4578-A871-24AA946BF34D')
        ,('Template', '6FBDE604-4178-42CE-A10B-8A2600A2F07D')
        ,('LockObject', '87A9F1FF-B1E4-4A25-BABB-465A4A47EC41')
        ,('RelationType', 'B1988FAD-8675-4F47-915A-B3A602BC5D8D') -- added in v9?
        ,('FormsForm', 'F5A9F787-6593-46F0-B8FF-BFD9BCA9F6BB') -- added in v9?
        ,('FormsPreValue', '42D7BF9B-A362-4FEE-B45A-674D5C064B70') -- added in v9?
        ,('FormsDataSource', 'CFED6CE4-9359-443E-9977-9956FEB1D867') -- added in v9?
        ,('Language', '6B05D05B-EC78-49BE-A4E4-79E274F07A77') -- added in v9?
        ,('IdReservation', '92849B1E-3904-4713-9356-F646F87C25F4') -- added in v9?

## Full node path query
The primary table, umbracoNode, is a self-referencing parent-child structure. This full node path query helps to unwrap and visualize that relationship

### Basic full path query as recursive CTE into table variable
    CREATE TABLE #FullPath (NodeId INT, fullpath VARCHAR(MAX), nodetext NVARCHAR(510), [Path] NVARCHAR(300), nodeObjectType UNIQUEIDENTIFIER, trashed BIT)
    -- or DECLARE @FullPath TABLE (NodeId INT, fullpath VARCHAR(MAX), nodetext NVARCHAR(510), [Path] NVARCHAR(300), nodeObjectType UNIQUEIDENTIFIER, trashed BIT)
    ; WITH cteFullPath AS 
    (
        SELECT id, 
        CAST('' AS VARCHAR(MAX)) AS fullpath,
            nodetext = [text], 
            [Path], 
            nodeObjectType, 
            trashed
        FROM umbracoNode WHERE id = -1
        UNION ALL
        SELECT umbracoNode.id, 
            CAST(cteFullPath.fullpath + '/' + umbracoNode.[text] AS VARCHAR(MAX)),
            umbracoNode.[text], 
            umbracoNode.[path], 
            umbracoNode.nodeObjectType, 
            umbracoNode.trashed
        FROM umbracoNode
            JOIN cteFullPath
                ON umbracoNode.parentID = cteFullPath.id
        WHERE umbracoNode.id <> -1
    )
    INSERT #FullPath (NodeId, fullpath, nodetext, PATH, nodeObjectType, trashed)
    SELECT NodeId = id, fullpath, nodetext, [path], nodeObjectType, trashed
    FROM cteFullPath

### Full Path as a view, using NodeObjectType table for NodeType
    CREATE VIEW [dbo].[vwFullPath] AS
_ cte query _
    SELECT NodeId, NodeText, FullPath, NodeType = NodeObjectType.Name, trashed
    FROM cteFullPath
        LEFT JOIN NodeObjectType
            ON cteFullPath.NodeObjectType = NodeObjectType.TypeId

## Database Queries

### Content Super-query
_Uses FullPath and NodeObjectType as temp tables_
    
    SELECT FullPath.NodeId,
        FullPath.fullpath,
        FullPath.NodeText,
        FullPath.path,
        NodeType = NodeObjectType.Name,
        ContentType = cmsContentType.alias,
        ContentDesc = cmsContentType.description,
      IsPublished = umbracoDocumentVersion.Published,
      Template = uTemplate.text
    FROM #FullPath AS FullPath
        JOIN #NodeObjectType AS NodeObjectType
            ON FullPath.nodeObjectType = NodeObjectType.TypeId
        LEFT JOIN umbracoContent
        ON FullPath.NodeId = umbracoContent.nodeId
        LEFT JOIN cmsContentType 
            ON umbracoContent.contentTypeId = cmsContentType.nodeId
      LEFT JOIN umbracoContentVersion
        ON FullPath.NodeId = umbracoContentVersion.nodeId
        AND umbracoContentVersion.[current] = 1
      LEFT JOIN umbracoDocumentVersion
        ON umbracoContentVersion.id = umbracoDocumentVersion.id
      LEFT JOIN cmsTemplate
        ON umbracoDocumentVersion.templateId = cmsTemplate.nodeId
      LEFT JOIN umbracoNode AS uTemplate
        ON cmsTemplate.nodeId = uTemplate.id
    WHERE FullPath.trashed = 0 AND
        FullPath.NodeId = <Node Id, int, >

### Properties Super-query
_Uses FullPath and NodeObjectType as temp tables_

    SELECT docNodeId = nodeDocument.id,
        NodeText = nodeDocument.text,
        propId = umbracoPropertyData.id,
        TypeId = umbracoPropertyData.propertytypeid,
        TypeAlias = cmsPropertyType.Alias,
        TypeName = cmsPropertyType.Name,
        TypeSchema = umbracoDataType.propertyEditorAlias, -- aka Type Data Type
        [int] = umbracoPropertyData.intValue,
        associatedNode.fullpath,
        [decimal] = umbracoPropertyData.decimalValue,
        [date] = umbracoPropertyData.dateValue,
        string = umbracoPropertyData.varcharValue,
        [text] = umbracoPropertyData.textValue
    FROM umbracoNode nodeDocument
        LEFT JOIN umbracoContent
            ON nodeDocument.id = umbracoContent.nodeId
        LEFT JOIN umbracoContentVersion
            ON umbracoContent.nodeId = umbracoContentVersion.nodeId
            AND umbracoContentVersion.[current] = 1
        LEFT JOIN umbracoPropertyData
            ON umbracoContentVersion.id = umbracoPropertyData.versionId
        LEFT JOIN cmsPropertyType
            ON umbracoPropertyData.propertytypeid = cmsPropertyType.id
        LEFT JOIN umbracoDataType
            ON cmsPropertyType.dataTypeId = umbracoDataType.nodeId
        LEFT JOIN #FullPath associatedNode
            ON associatedNode.NodeId = umbracoPropertyData.intValue
        LEFT JOIN umbracoDocument
            ON nodeDocument.id = umbracoDocument.nodeId
    WHERE (umbracoDocument.nodeId IS NULL OR umbracoDocument.published = 1) AND
        nodeDocument.id = <Node Id, int, >

# Umbraco v7

## Database Queries

### Explore the cmsDocumentType table
    ; WITH dt AS (SELECT id, text FROM umbracoNode WHERE nodeObjectType = 'A2CB7800-F571-4787-9638-BC48539A0EFB')
    SELECT dtid = dt.id, dtName = dt.text,
        templateNode = templateNode.text
    FROM dt
        LEFT JOIN cmsDocumentType cdt
            ON dt.id = cdt.contentTypeNodeId
        LEFT JOIN umbracoNode templateNode
            ON templateNode.id = cdt.templateNodeId

### Explore the cmsTemplate table
    ; WITH n AS (SELECT id, text, objtype = nodeObjectType, parentID FROM umbracoNode)
    SELECT templateNode = templateNode.text, masterNode = masterNode.text, t.*
    FROM cmsTemplate t
        LEFT JOIN n templateNode
            ON templateNode.id = t.nodeId
        LEFT JOIN n masterNode
            ON masterNode.id = templateNode.parentID
            AND templateNode.parentID <> -1

### Explore the cmsContent table
    ; WITH n AS (SELECT id, text, objtype = nodeObjectType FROM umbracoNode)
    SELECT cnode = cnode.text, typeNode = typeNode.text, 
        c.*
    FROM cmsContent c
        LEFT JOIN n cnode
            ON cnode.id = c.nodeId
        LEFT JOIN n typeNode
            ON typeNode.id = c.contentType

### Explore the cmsDocument table
    ; WITH n AS (SELECT id, text, objtype = nodeObjectType FROM umbracoNode)
    SELECT templatenode = templatenode.text,
        d.*
    FROM cmsDocument d
        LEFT JOIN n templatenode
            ON templatenode.id = d.templateId

### Explore Data Types
    ; WITH cteDataType AS (
        SELECT DataTypeId = cmsDataType.pk, DataTypeNodeId = cmsDataType.nodeId, 
            DataTypeName = umbracoNode.text, cmsDataType.propertyEditorAlias, cmsDataType.dbType, 
            IsSystem = CAST(CASE WHEN umbracoNode.id < 0 THEN 1 ELSE 0 END AS BIT)
        FROM cmsDataType
            JOIN umbracoNode
                ON cmsDataType.nodeId = umbracoNode.id
    )
    SELECT cteDataType.DataTypeId,
        cteDataType.DataTypeNodeId,
        cteDataType.DataTypeName,
        cteDataType.propertyEditorAlias,
        PropTypeName = cmsPropertyType.Name,
        PropTypeContentTypeId = cmsPropertyType.contentTypeId
    FROM cteDataType
        LEFT JOIN cmsPropertyType
            ON cmsPropertyType.dataTypeId = cteDataType.DataTypeNodeId
    WHERE cteDataType.IsSystem = 0
    ORDER BY cteDataType.DataTypeId DESC

### Page Count by Type
    SELECT ContentTypeName = ctn.Text, Cnt = COUNT(*)
    FROM umbraconode ctn
        JOIN cmsContent c
            ON c.contentType = ctn.id
    GROUP BY ctn.id, ctn.text
    ORDER BY ctn.text

### Cleanup invalid characters in media
    SELECT * FROM cmsPropertyData WHERE dataNvarchar LIKE '%&%' AND propertytypeid = 6
    UPDATE cmsPropertyData SET dataNvarchar = REPLACE(dataNvarchar, '-&', '') WHERE dataNvarchar LIKE '%&%' AND propertytypeid = 6


### Find unused data types
    ; WITH cteDataType AS (
        SELECT dtId = cmsDataType.pk, dtNodeId = cmsDataType.nodeId, 
            dtName = umbracoNode.text, dtAlias = cmsDataType.propertyEditorAlias, cmsDataType.dbType, 
            IsSystem = CAST(CASE WHEN umbracoNode.id < 0 THEN 1 ELSE 0 END AS BIT)
        FROM cmsDataType
            JOIN umbracoNode
                ON cmsDataType.nodeId = umbracoNode.id
    )
    SELECT cteDataType.dtId,
        cteDataType.dtNodeId,
        cteDataType.dtName,
        cteDataType.dtAlias,
        ptName = cmsPropertyType.Name,
        ptContentTypeId = cmsPropertyType.contentTypeId,
        ptgName = cmsPropertyTypeGroup.text,
        vwFullPath.*
    FROM cteDataType
        LEFT JOIN cmsPropertyType
            ON cmsPropertyType.dataTypeId = cteDataType.dtNodeId
        LEFT JOIN cmsPropertyTypeGroup
            ON cmsPropertyType.propertyTypeGroupId = cmsPropertyTypeGroup.id
        LEFT JOIN vwFullPath
            ON vwFullPath.NodeId = cmsPropertyTypeGroup.contenttypeNodeId
    WHERE cteDataType.IsSystem = 0 AND
        vwFullPath.NodeId IS NULL
    ORDER BY cteDataType.dtName



## Other Notes

### Republish even the database-stored XML

Navigate to `~/Umbraco/dialogs/republish.aspx?xml=true` (`&previews=true` also does something (unknown))
    
    http://YOURDOMAIN/Umbraco/dialogs/republish.aspx?xml=true


