import java.util.Arrays;

import javax.swing.JOptionPane;

public class Message {
    public static void main(String[] args) {
        if (args[0].equals("output"))
            JOptionPane.showMessageDialog(null, args[1]);
        else if (args[0].equals("input")) {
            var res = JOptionPane.showInputDialog(null, args[1]);
            System.out.println(res);
        }
    }
}