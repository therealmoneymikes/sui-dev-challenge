"use client";
import React, { ReactElement } from "react";
import { AiFillHome, AiFillStar } from "react-icons/ai";
import HomeComponent from "./components/HomeComponent";

/**
 * 
 * 
 * @copyright Made My Michael Roberts https://github.com/therealmoneymikes
 * 
 * 
 */
interface IMenuProps {
  id: string
  icon: React.ReactElement;
  title: string;
  component: ReactElement
}

interface INavbarProps {
  scrollToSection: (id: string) => void;
}

  export const menu: IMenuProps[] = [
    {
      id: "home",
      icon: <AiFillHome />,
      title: "Home",
      component: <HomeComponent />,
    },
    {
      id: "story",
      icon: <AiFillHome />,
      title: "Our Story",
      component: <HomeComponent />,
    },
    {
      id: "roadmap",
      icon: <AiFillStar />,
      title: "Roadmap",
      component: <HomeComponent />,
    },
    {
      id: "utility",
      icon: <AiFillHome />,
      title: "Utility",
      component: <HomeComponent />,
    },
  ];
const Navbar: React.FC<INavbarProps> = ({scrollToSection}) => {

  return (
    <div>
      <nav className="flex flex-row justify-center items-center space-x-4 font-HoneyBear">
        {menu.map((option: IMenuProps) => (
          <button
            key={option.title}
            className="display: flex flex-row space-x-1 items-center"
            onClick={() => scrollToSection(option.id)}
          >
            <div>{option.icon}</div>
            <p className="text-sm md:text-xs text-nowrap">{option.title}</p>
          </button>
        ))}
      </nav>
    </div>
  );
};

export default Navbar;
