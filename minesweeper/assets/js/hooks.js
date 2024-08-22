let Hooks = {}

Hooks.FlagCell = {
  mounted() {
    this.el.addEventListener("contextmenu", (e) => {
      e.preventDefault();
      let row = this.el.getAttribute("data-row");
      let col = this.el.getAttribute("data-col");

      this.pushEvent("toggle_flag", { row: row, col: col });
    });
  }
}

export default Hooks;
