import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "discord-mirror",

  initialize() {
    withPluginApi("1.0.0", (api) => {
      // Override name display for bot users to always show the name field
      api.modifyClass(
        "component:chat/message/info",
        (Superclass) =>
          class extends Superclass {
            get name() {
              const user = this.args.message?.user;
              // For bot users (negative ID), always show the name field
              if (user?.id < 0 && user?.name) {
                return user.name;
              }
              return super.name;
            }
          }
      );
    });
  },
};
