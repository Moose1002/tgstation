import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dropdown, LabeledList, Section, Stack, Tabs, Table, TextArea } from '../components';
import { Window } from '../layouts';

export const RequestsConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useLocalState(context, 'tab', "messages");
  const {
    announcement_console,
  } = data;
  return (
    <Window
      width={600}
      height={500}>
      <Window.Content scrollable>
        <Section fitted>
          <Tabs>
            <Tabs.Tab
              selected={tab === "messages"}
              onClick={() => setTab("messages")}>
              Messages
            </Tabs.Tab>
            <Tabs.Tab
              selected={tab === "request"}
              onClick={() => setTab("request")}>
              Request
            </Tabs.Tab>
            <Tabs.Tab
              selected={tab === "emergency"}
              onClick={() => setTab("emergency")}>
              Emergencies
            </Tabs.Tab>
            {announcement_console === true && (
              <Tabs.Tab
                selected={tab === "announce"}
                onClick={() => setTab("announce")}>
                Announce
              </Tabs.Tab>
            )}
          </Tabs>
        </Section>
        {tab === "messages" && (
          <RequestsConsoleMessage />
        )}
        {tab === "request" && (
          <RequestsConsoleRequest />
        )}
        {tab === "emergency" && (
          <RequestsConsoleEmergencies />
        )}
        {tab === "announce" && (
          <RequestsConsoleAnnouncements />
        )}
      </Window.Content>
    </Window>
  );
};

export const RequestsConsoleMessageList = (props, context) => {
  const { act, data } = useBackend(context);
  const messages = data.messages || [];
  return (
    <Section
      title="Messages"
      buttons={
        <Button
          icon={data.silent ? 'volume-mute' : 'volume-up'}
          selected={!data.silent}
          onClick={() => act('silence')} />
      }>
      {messages.length === 0 && (
        <Box color="good">
          No Messages
        </Box>
      )}
      {messages.length > 0 && (
        <Table>
          {messages.map(message => (
            <Table.Row
              key={message.source}>
              <Table.Cell>
                From: {message.source}
              </Table.Cell>
              <Table.Cell>
                Received: {message.creation_time}
              </Table.Cell>
              <Table.Cell textAlign="right">
                <Button
                  icon="envelope"
                  onClick={() => act('open_message', {
                    id: message.id,
                  })} />
                <Button.Confirm
                  icon="trash"
                  onClick={() => act('delete_message', {
                    id: message.id,
                  })} />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

export const RequestsConsoleRequest = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    message,
    message_priority,
    message_verification,
    message_stamped,
  } = data;
  return (
    <Section
      title="Create Request">
      <DepartmentDropdown />
      <Button
        content="Normal Priority"
        selected={message_priority === 1}
        onClick={() => act("set_message_priority", {
          priority: 1,
        })} />
      <Button
        content="High Priority"
        selected={message_priority === 2}
        onClick={() => act("set_message_priority", {
          priority: 2,
        })} />
      <Button
        content="Extreme Priority"
        color="bad" />
      <TextArea
        height="200px"
        mb={1}
        value={message}
        onChange={(e, value) => act("set_message", {
          message: value,
        })} />
      <LabeledList>
        <LabeledList.Item label="Verified by">
          {message_verification ? message_verification : "Unverified"}
        </LabeledList.Item>
        <LabeledList.Item label="Stamped by">
          {message_stamped ? message_stamped : "Unstamped"}
        </LabeledList.Item>
      </LabeledList>
      <Box mt={1} />
      <Button.Confirm
        icon="check"
        color="good"
        content="Send Message"
        onClick={() => act("send_message")} />
    </Section>
  );
};

export const RequestsConsoleEmergencies = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Section
      title="Emergencies"
    />
  );
};

export const DepartmentDropdown = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Stack>
      <Stack.Item grow>
        <Dropdown
          width="75%"
          selected={data.recipient_department ? data.recipient_department : "Recipient Department..."}
          options={data.assistance_departments}
          onSelected={sel => act("set_message_department", {
            department: sel,
          })} />
      </Stack.Item>
    </Stack>
  );
};

export const RequestsConsoleMessage = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    active_message,
    active_message_id,
    active_message_source,
    active_message_creation_time,
    active_message_content,
    active_message_verified,
    active_message_stamped,
  } = data;
  if (!active_message) {
    return <RequestsConsoleMessageList />;
  }
  return (
    <>
      <Section
        title={"Request From: " + active_message_source}
        buttons={
          <>
            <Button
              icon="arrow-left"
              content="Back"
              onClick={() => act("exit_message")} />
            <Button.Confirm
              icon="trash"
              onClick={() => act('delete_message', {
                id: active_message_id,
              })} />
          </>
        }>
        <LabeledList>
          <LabeledList.Item label="Received">
            {active_message_creation_time}
          </LabeledList.Item>
          <LabeledList.Item label="From">
            {active_message_source}
          </LabeledList.Item>
          <LabeledList.Item label="Verified by">
            {active_message_verified ? active_message_verified : "Unverified"}
          </LabeledList.Item>
          <LabeledList.Item label="Stamped by">
            {active_message_stamped ? active_message_stamped : "Unstamped"}
          </LabeledList.Item>
          <LabeledList.Item label="Message">
            {active_message_content}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </>
  );
};
