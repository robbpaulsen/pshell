function Show-Network {
    param($n)

    $script:nodes=@{}
    $script:nodelist=@()
    $script:id=0

    function Get-NodeID {
        param($p)

        [int]$targetId=$script:nodes.$p
        if(!$targetId) {        
            $script:id++
            $targetId = $script:id
            $script:nodes.$p = $targetId
        }
        $targetId
    }

    function Add-Edge {
        param(
            $source,
            $target
        )

        $sourceID = Get-NodeID $source
        $targetID = Get-NodeID $target
    
        $script:nodelist += [PSCustomObject]@{
            from = $sourceID
            to = $targetID
        
        }
    }

    $n.split("`n") | % {
        $source,$target = $_.split('>')

        Add-Edge $source.trim() $target.trim()
    }

$html = @"
<html>
  <head>
    <title>Network</title>
    <script
      type="text/javascript"
      src="https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"
    ></script>
    <style type="text/css">
      #mynetwork {{
        width: 600px;
        height: 400px;
        border: 1px solid lightgray;
      }}
    </style>
  </head>
  <body>
    <div id="mynetwork"></div>
    <script type="text/javascript">
      // create an array with nodes
      var nodes = new vis.DataSet({0});

      // create an array with edges
      var edges = new vis.DataSet({1});

      // create a network
      var container = document.getElementById("mynetwork");
      var data = {{
        nodes: nodes,
        edges: edges,
      }};
      var options = {{}};
      var network = new vis.Network(container, data, options);
    </script>
  </body>
</html>
"@

    $edges = $script:nodelist | ConvertTo-Json -Compress
    $targetNodes = $nodes.GetEnumerator() | % {
        [PSCustomObject]@{
            id    = $_.value
            label = $_.name
        }
    } | ConvertTo-Json -Compress


    $htmlFile="$env:TEMP\testviz.html"
    ($html -f $targetNodes, $edges) | Set-Content $htmlFile
    Invoke-Item $htmlFile
    $htmlFile
}