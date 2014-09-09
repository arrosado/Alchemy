class alchemy.models.Node
    constructor: (node) ->
        conf = alchemy.conf
        
        @id = node.id
        @_style = alchemy.svgStyles.node.populate(@)
        @_properties = node
        @_state = { "active": true }
        @_d3 = _.assign({'id': @id, 'root': @_properties[conf.rootNodes]}, @_style)
        @_adjacentEdges = []
        @_nodeType = @_setNodeType()
                    
    # internal methods
    _setNodeType: =>
        conf = alchemy.conf
        if conf.nodeTypes
            if _.isPlainObject(conf.nodeTypes)
                lookup = Object.keys(alchemy.conf.nodeTypes)
                types = _.values(conf.nodeTypes)
                nodeType = @_properties[lookup]
                if types.indexOf(nodeType)
                    @_d3['nodeType'] = nodeType
                    nodeType
            else if typeof conf.nodeTypes is 'string'
                nodeType = @_properties[conf.nodeTypes]
                if nodeType
                    @_setD3Properties('nodeType', nodeType)
                    nodeType

    _setD3Properties: (props) =>
        # set d3 properties
        _.assign(@_d3, props)

    _addEdge: (edge) ->
        # Stores edge.id for easy edge lookup
        @_adjacentEdges = _.union(@_adjacentEdges, edge)
    
    # Edit node properties
    getProperties: (key=null, keys...) =>
    	if not key? and (keys.length is 0)
            @_properties
        else if keys.length isnt 0
            query = _.union([key], keys)
            _.pick(@_properties, query)
        else
            @_properties[key]

    setProperty: (property, value=null) =>
        if _.isPlainObject(property)
            _.assign(@_properties, property)
            @
        else
            @_properties[property] = value
            @
    
    removeProperty: (property) =>
        if @_properties.property?
            _.omit(@_properties, property)
            @
            
    
    # Style methods
    getStyles: (key=null) =>
        if key?
            @_style[key]
        else
            @_style

    setStyles: (key, value) =>
        # takes a key, value or map of key values
        # the user passes a map of styles to set multiple styles at once
        if typeof key isnt "string"
            # use lodash, _.isPlainObject() test here...
            value = ""
            _.assign(@_style, key)
            @_setD3Properties(@_style)
            alchemy._drawNodes.updateNode(@_d3)
            @
        else
            @_style[key] = value
            @_setD3Properties(@_style)
            alchemy._drawNodes.updateNode(@_d3)
            @

    # Convenience methods
    outDegree: () -> @_adjacentEdges.length

    neighbors: () ->
        # Find connected nodes
        regex = new RegExp("[(#{@id}#{'\\'}-)(#{'\\'}-#{@id})]","g")
        _.map @adjacentEdges, (edgeID)->  edgeID.replace(regex, "")

