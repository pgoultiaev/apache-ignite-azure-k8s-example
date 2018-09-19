package nl.acme.app;

public class Address {
    private String address;
    private int pc;

	public Address(String address, int pc) {
        this.address = address;
        this.pc = pc;
	}

    /**
     * @return the pc
     */
    public int getPc() {
        return pc;
    }

    /**
     * @param pc the pc to set
     */
    public void setPc(int pc) {
        this.pc = pc;
    }

    /**
     * @return the address
     */
    public String getAddress() {
        return address;
    }

    /**
     * @param address the address to set
     */
    public void setAddress(String address) {
        this.address = address;
    }

    public String toString() {
        return this.address + " " + this.pc;
    }

}