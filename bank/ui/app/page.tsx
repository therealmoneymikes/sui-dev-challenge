
import { useState, useCallback, useRef, useEffect } from "react";
import { motion } from "framer-motion";
import dynamic from "next/dynamic";

import { Spinner } from "@radix-ui/themes";
import { menu } from "@/app/Navbar";
import { AiFillInstagram, AiFillDiscord, AiOutlineArrowUp } from "react-icons/ai";
const NavbarNoSSR = dynamic(() => import("@/app/Navbar"), { ssr: false });
export default function Home() {
  
    
  const [walletAddress, setWalletAddress] = useState<string>("");
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [availableNfts, setAvailableNfts] = useState<number>(9999);
  //
  //Handle Accounts Changed
  const handleAccountsChanged = (accounts: string[]) => {
    setWalletAddress(accounts.length > 0 ? accounts[0] : "");
  };
  //Fetch Crypto Wallets:

  //Connect Wallet Accounts
  const connectWallet = async () => {
    
  };

  //Get current wallet
  const GetCurrentWallet = useCallback(async () => {
    
  }, []);

  // Add Wallet Listener

  const AddWalletListener = useCallback(async () => {
    
  }, []);

  //Section Refs
  const sectionRef = useRef<HTMLDivElement>({} as HTMLDivElement);
  const sectionRefs = menu.reduce((menu, item) => {
    menu[item.id] = sectionRef;
    return menu;
  }, {} as Record<string, React.RefObject<HTMLDivElement>>);

  const scrollToSection = (id: string) => {
    const element = document.getElementById(id);
    element?.scrollIntoView({ behavior: "smooth" });
  };
  useEffect(() => {
   
  }, [GetCurrentWallet, AddWalletListener, walletAddress]);
  return (
    <div className="min-h-screen min-w-max p-8 pb-16 ">
      <main className="flex flex-row items-center justify-between space-x-3">
        <section id="top">
          <NavbarNoSSR scrollToSection={scrollToSection} />
        </section>

        {/* Connect and social tags */}
        <div className="flex flex-row items-center justify-evenly">
          <AiFillInstagram size={34} />
          <AiFillDiscord size={34} />
          <motion.button
            disabled={isLoading}
            style={{ border: "4px solid white" }}
            onClick={connectWallet}
            className="display: flex flex-row w-32 h-12 mx-4 items-center justify-center font-bold border rounded-md p-3 hover:cursor-pointer bg-pink-700"
          >
            <p className="font-HoneyBear text-xs tracking-widest ">
              {isLoading ? (
                <Spinner size={"2"} />
              ) : walletAddress.length > 0 ? (
                `${walletAddress.substring(0, 3)}...${walletAddress.substring(
                  walletAddress.length - 5
                )}`
              ) : (
                "Connect"
              )}
            </p>
          </motion.button>
        </div>
      </main>
      {menu.map((section) => (
        <section
          key={section.id}
          id={section.id}
          ref={sectionRefs[section.id]}
          className="min-h-screen p-5 flex flex-col items-center justify-between space-x-3"
        >
          {section.component}
        </section>
      ))}

      <motion.button
        onClick={() => scrollToSection("top")}
        whileHover={{ scale: 1.1 }}
        className="fixed"
        style={{ bottom: "10%", right: "5%" }}
      >
        <AiOutlineArrowUp
          size={35}
          className="bg-orange-700 border rounded-md"
        />
      </motion.button>
    </div>
  );
}
