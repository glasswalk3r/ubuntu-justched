public class JvmDetails {

    public static void main(String[] args) {
        System.out.println(System.getProperty("java.version"));
        System.out.println(System.getProperty("sun.arch.data.model"));
        System.out.println(System.getProperty("java.vm.vendor"));
    }

}
