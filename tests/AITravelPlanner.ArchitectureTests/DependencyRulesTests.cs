using System.Xml.Linq;

namespace AITravelPlanner.ArchitectureTests;

public sealed class DependencyRulesTests
{
    [Theory]
    [InlineData("Domain", "")]
    [InlineData("Application", "AITravelPlanner.Domain")]
    [InlineData("Infrastructure", "AITravelPlanner.Domain,AITravelPlanner.Application")]
    [InlineData("WebApi", "AITravelPlanner.Application,AITravelPlanner.Infrastructure")]
    public void Production_projects_only_reference_allowed_layers(
        string layer, string allowedProjectNames)
    {
        // Arrange: the architecture rule lists allowed dependencies, not required ones.
        var project = LoadProject(layer);
        var allowed = allowedProjectNames.Split(',', StringSplitOptions.RemoveEmptyEntries);

        // Act: inspect declared project references in the real repository.
        var references = project.Descendants("ProjectReference")
            .Select(reference => reference.Attribute("Include")!.Value.Replace('\\', '/'))
            .Select(Path.GetFileNameWithoutExtension);

        // Assert: even conditional references must respect the layer boundary.
        foreach (var reference in references)
        {
            Assert.Contains(reference, allowed);
        }
    }

    [Theory]
    [InlineData("Domain")]
    [InlineData("Application")]
    public void Core_layers_do_not_reference_web_frameworks(string layer)
    {
        var project = LoadProject(layer);

        var frameworks = project.Descendants("FrameworkReference");

        Assert.Empty(frameworks);
    }

    private static XDocument LoadProject(string layer)
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);
        while (directory is not null)
        {
            if (File.Exists(Path.Combine(directory.FullName, "AI_Travel_Planner.sln")))
            {
                return XDocument.Load(Path.Combine(
                    directory.FullName, "src", layer, $"AITravelPlanner.{layer}.csproj"));
            }

            directory = directory.Parent;
        }

        throw new DirectoryNotFoundException("Cannot locate the repository solution.");
    }
}
