import logo from "../assets/logo.png";

const Logo: React.FC = () => {
	return (
		<img
			src={logo}
			alt="Smart Labs Logo"
			className="w-20 h-20 rounded-full shadow-md"
		/>
	);
};

export default Logo;
