import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import net.irisshaders.iris.shaderpack.parsing.ConstDirectiveParser;
import net.irisshaders.iris.shaderpack.parsing.DispatchingDirectiveHolder;
import org.joml.Vector4f;

/** Runs only Iris's directive parser. No Minecraft startup or OpenGL context. */
public class IrisDirectiveCheck {
    public static void main(String[] sources) throws Exception {
        Map<String, String> expected = Map.of(
            "colortex0Format", "RGB8",
            "colortex1Format", "R11F_G11F_B10F",
            "colortex2Format", "R8",
            "colortex4Format", "R11F_G11F_B10F"
        );
        for (String source : sources) {
            Map<String, String> actual = new HashMap<>();
            boolean[] clears = {false};
            Vector4f[] clearColor = {null};
            DispatchingDirectiveHolder holder = new DispatchingDirectiveHolder();
            for (String name : expected.keySet()) {
                holder.acceptConstStringDirective(name, value -> actual.put(name, value));
            }
            holder.acceptConstBooleanDirective("colortex2Clear", value -> clears[0] = value);
            holder.acceptConstVec4Directive("colortex2ClearColor", value -> clearColor[0] = value);
            for (var directive : ConstDirectiveParser.findDirectives(Files.readString(Path.of(source)))) {
                holder.processDirective(directive);
            }
            if (!actual.equals(expected) || !clears[0] || clearColor[0] == null
                || clearColor[0].x != 0.0f || clearColor[0].y != 0.0f
                || clearColor[0].z != 0.0f || clearColor[0].w != 0.0f) {
                throw new AssertionError("Unexpected Iris buffer directives in " + source + ": " + actual);
            }
        }
        System.out.println("PASS: installed Iris parsed format and hand-mask clear directives for "
            + sources.length + " composite programs.");
    }
}
