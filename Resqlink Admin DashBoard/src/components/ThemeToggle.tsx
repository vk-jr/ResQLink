import { Moon, Sun } from "lucide-react"
import { Button } from "@/components/ui/button"
import { useTheme } from "@/hooks/use-theme"

export function ThemeToggle() {
  const { theme, toggleTheme } = useTheme()

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={toggleTheme}
      className="h-9 w-9 rounded-lg hover:bg-secondary relative"
    >
      <Sun className={`h-5 w-5 transition-all duration-200 ${
        theme === 'dark' ? 'opacity-100 rotate-0' : 'opacity-0 -rotate-90'
      }`} />
      <Moon className={`h-5 w-5 transition-all duration-200 absolute ${
        theme === 'dark' ? 'opacity-0 rotate-90' : 'opacity-100 rotate-0'
      }`} />
      <span className="sr-only">Toggle theme</span>
    </Button>
  )
}
